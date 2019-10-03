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
SET PREFIXLOWER=mygamebackend

REM # Variables for creating the storage account and the container
SET STORAGENAME=%PREFIX%STRG
SET STORAGENAMELOWER=%PREFIXLOWER%strg%RANDOM%
SET STORAGENAMEUNIQUE=%STORAGENAMELOWER%%RANDOM%
SET STORAGESKU=Standard_LRS
SET STORAGECONTAINERNAME=%STORAGENAMELOWER%cntnr
SET STORAGESUBNETNAME=%STORAGENAME%Subnet
SET STORAGESUBNETADDRESSPREFIX=10.0.3.0/24
SET STORAGERULENAME=%STORAGENAME%Rule
REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Creating a storage account named %STORAGENAME%
CALL az storage account create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %STORAGENAMEUNIQUE% ^
 --sku %STORAGESKU% ^
 --location %REGIONNAME%

ECHO Getting the connection string from the storage account
CALL az storage account show-connection-string -n %STORAGENAMEUNIQUE% -g %RESOURCEGROUPNAME% --query connectionString -o tsv > connectionstring.tmp
SET /p STORAGECONNECTIONSTRING=<connectionstring.tmp
CALL DEL connectionstring.tmp

ECHO Creating a storage container named %STORAGECONTAINERNAME% into the storage account named %STORAGENAMEUNIQUE%
CALL az storage container create ^
 --name %STORAGECONTAINERNAME% ^
 --connection-string %STORAGECONNECTIONSTRING%

ECHO Enabling service endpoint for Azure Storage on the Virtual Network and subnet
CALL az network vnet subnet create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --vnet-name %VNETNAME% ^
 --name %STORAGESUBNETNAME% ^
 --service-endpoints Microsoft.Storage ^
 --address-prefix %STORAGESUBNETADDRESSPREFIX%

ECHO Adding a network rule for a virtual network and subnet
CALL az network vnet subnet show --resource-group %RESOURCEGROUPNAME% --vnet-name %VNETNAME% --name %STORAGESUBNETNAME% --query id --output tsv > storagesubnetid.tmp
SET /p STORAGESUBNETID=<storagesubnetid.tmp
CALL DEL storagesubnetid.tmp

CALL az storage account network-rule add ^
 --resource-group %RESOURCEGROUPNAME% ^
 --account-name %STORAGENAMEUNIQUE% ^
 --subnet %STORAGESUBNETID% ^