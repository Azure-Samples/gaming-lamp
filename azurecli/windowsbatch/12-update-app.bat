@echo off
REM #############################################################################################
REM # Ensure you have logged in to Azure with your credentials prior to running this script
REM # az login

REM # Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
REM # "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
REM #############################################################################################

REM #############################################################################################
REM # General variables used in the different Azure CLI commands run from this script
SET YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
SET RESOURCEGROUPNAME=myResourceGroup
SET REGIONNAME=japanwest
SET PREFIX=myGameBackend

REM # Variables storing the storage account, blob file to update and updating script
SET BLOBSOURCEURI=app\\package.tar.gz
SET BLOBFILEDESTINATIONNAME=package.tar.gz
SET SCRIPTUPDATESOURCEURI=scripts\\update-app.sh
SET SCRIPTUPDATEFILEDESTINATIONAME=update-app.sh
SET DESTINATIONFOLDER=/var/www/html
SET SERVICETORESTART=apache2.service

# Change the storage name and container to the ones previously created
SET STORAGENAME=mygamebackendstrg%RANDOM%
SET STORAGECONTAINERNAME=%STORAGENAME%cntnr

SET VMSSNAME=%PREFIX%VMSS
REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Getting the connection string from the storage account
CALL az storage account show-connection-string -n %STORAGENAME% -g %RESOURCEGROUPNAME% --query connectionString -o tsv > connectionstring.tmp
SET /p STORAGECONNECTIONSTRING=<connectionstring.tmp
CALL DEL connectionstring.tmp

ECHO Uploading both the application files and update application script to the blob storage
REM # https://docs.microsoft.com/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-upload
CALL az storage blob upload ^
 -c %STORAGECONTAINERNAME% ^
 -f %BLOBSOURCEURI% ^
 -n %BLOBFILEDESTINATIONNAME% ^
 --connection-string %STORAGECONNECTIONSTRING%

CALL az storage blob upload ^
 -c %STORAGECONTAINERNAME% ^
 -f %SCRIPTUPDATESOURCEURI% ^
 -n %SCRIPTUPDATEFILEDESTINATIONAME% ^
 --connection-string %STORAGECONNECTIONSTRING%

CALL az storage blob url -c %STORAGECONTAINERNAME% -n %BLOBFILEDESTINATIONNAME% -o tsv --connection-string %STORAGECONNECTIONSTRING% > bloburl.tmp
SET /p BLOBURL=<bloburl.tmp
CALL DEL bloburl.tmp

CALL az storage blob url -c %STORAGECONTAINERNAME% -n %SCRIPTUPDATEFILEDESTINATIONAME% -o tsv --connection-string %STORAGECONNECTIONSTRING% > scripturl.tmp
SET /p SCRIPTURL=<scripturl.tmp
CALL DEL scripturl.tmp

ECHO %BLOBURL%
ECHO %SCRIPTURL%

REM # Building the Protected Settings JSON string, which will be used by the Custom Script Extension to download the file or files from the storage account
CALL az storage account keys list --account-name %STORAGENAME% --resource-group %RESOURCEGROUPNAME% --query [0].value --output tsv > storagekey.tmp
SET /p STORAGEKEY=<storagekey.tmp
CALL DEL storagekey.tmp

SET PROTECTEDSETTINGS="{\"storageAccountName\":\"%STORAGENAME%\",\"storageAccountKey\":\"%STORAGEKEY%\"}"
SET SETTINGS="{\"fileUris\":[\"%BLOBURL%\",\"%SCRIPTURL%\"],\"commandToExecute\":\"bash %SCRIPTUPDATEFILEDESTINATIONAME% %BLOBFILEDESTINATIONNAME% %DESTINATIONFOLDER% %SERVICETORESTART%\"}"

ECHO Updating the configuration file from the virtual machine scale set %VMSSNAME% to download and install the file %BLOBFILEDESTINATIONNAME% from the blob storage account %STORAGENAME% in the next update round
CALL az vmss extension set ^
 --resource-group %RESOURCEGROUPNAME% ^
 --vmss-name %VMSSNAME% ^
 --publisher Microsoft.Azure.Extensions ^
 --name CustomScript ^
 --version 2.0 ^
 --settings %SETTINGS% ^
 --force-update ^
 --protected-settings %PROTECTEDSETTINGS%

ECHO Updating all the instances from the virtual machine scale set %VMSSNAME%
CALL az vmss update-instances ^
 --instance-ids * ^
 --name %VMSSNAME% ^
 --resource-group %RESOURCEGROUPNAME%
