#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export RESOURCEGROUPNAME=myResourceGroup
export REGIONNAME=japanwest
export PREFIX=myGameBackend

# Variables storing the storage account, blob file to update and updating script
export BLOBSOURCEURI=./app/package.tar.gz
export BLOBFILEDESTINATIONNAME=package.tar.gz
export SCRIPTUPDATESOURCEURI=./scripts/update-app.sh
export SCRIPTUPDATEFILEDESTINATIONAME=update-app.sh
export DESTINATIONFOLDER=/var/www/html
export SERVICETORESTART=apache2.service

export RANDOMNUMBER=`head -200 /dev/urandom | cksum | cut -f2 -d " "`
export STORAGENAME=mygamebackendstrg${RANDOMNUMBER}
export STORAGECONTAINERNAME=${STORAGENAME}cntnr

export VMSSNAME=${PREFIX}VMSS
#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Getting the connection string from the storage account
export STORAGECONNECTIONSTRING=`az storage account show-connection-string -n $STORAGENAME -g $RESOURCEGROUPNAME --query connectionString -o tsv`

echo Uploading both the application files and update application script to the blob storage
# https://docs.microsoft.com/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-upload
az storage blob upload \
 -c $STORAGECONTAINERNAME \
 -f $BLOBSOURCEURI \
 -n $BLOBFILEDESTINATIONNAME \
 --connection-string $STORAGECONNECTIONSTRING

az storage blob upload \
 -c $STORAGECONTAINERNAME \
 -f $SCRIPTUPDATESOURCEURI \
 -n $SCRIPTUPDATEFILEDESTINATIONAME \
 --connection-string $STORAGECONNECTIONSTRING

export BLOBURL=`az storage blob url -c $STORAGECONTAINERNAME -n $BLOBFILEDESTINATIONNAME -o tsv --connection-string $STORAGECONNECTIONSTRING`
export SCRIPTURL=`az storage blob url -c $STORAGECONTAINERNAME -n $SCRIPTUPDATEFILEDESTINATIONAME -o tsv --connection-string $STORAGECONNECTIONSTRING`

# Building the Protected Settings JSON string, which will be used by the Custom Script Extension to download the file or files from the storage account
export STORAGEKEY=`az storage account keys list --account-name $STORAGENAME --resource-group $RESOURCEGROUPNAME --query [0].value --output tsv`
export PROTECTEDSETTINGS="{\"storageAccountName\":\"${STORAGENAME}\",\"storageAccountKey\":\"${STORAGEKEY}\"}"
export SETTINGS="{\"fileUris\":[\"${BLOBURL}\",\"${SCRIPTURL}\"],\"commandToExecute\":\"bash ${SCRIPTUPDATEFILEDESTINATIONAME} ${BLOBFILEDESTINATIONNAME} ${DESTINATIONFOLDER} ${SERVICETORESTART}\"}"

echo Updating the configuration file from the virtual machine scale set $VMSSNAME to download and install the file $BLOBFILEDESTINATIONNAME from the blob storage account $STORAGENAME in the next update round
az vmss extension set \
 --resource-group $RESOURCEGROUPNAME \
 --vmss-name $VMSSNAME \
 --publisher Microsoft.Azure.Extensions \
 --name CustomScript \
 --version 2.0 \
 --settings $SETTINGS \
 --force-update \
 --protected-settings $PROTECTEDSETTINGS

echo Updating all the instances from the virtual machine scale set $VMSSNAME
az vmss update-instances \
 --instance-ids * \
 --name $VMSSNAME \
 --resource-group $RESOURCEGROUPNAME
