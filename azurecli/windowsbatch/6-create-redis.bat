@echo off
REM #############################################################################################
REM # Ensure you have logged in to Azure with your credentials prior to running this script
REM # az login

REM # Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
REM # "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

REM All redis cache need to have a unique name across Azure, so you can't use a common name like myRedis
REM #############################################################################################

REM #############################################################################################
REM # General variables used in the different Azure CLI commands run from this script
SET YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
SET RESOURCEGROUPNAME=myResourceGroup
SET REGIONNAME=japanwest
SET PREFIX=myGameBackend

REM # Variables for setting up the redis cache
SET REDISNAME=%PREFIX%Redis
SET REDISNAMEUNIQUE=%REDISNAME%%RANDOM%
SET REDISVMSIZE=C1
SET REDISSKU=Standard
SET REDISSHARDSTOCREATE=10
SET VNETNAME=%PREFIX%VNET
SET REDISSUBNETNAME=%REDISNAME%Subnet
SET REDISSUBNETADDRESSPREFIX=10.0.1.0/24
SET SUBNETID=/subscriptions/%YOURSUBSCRIPTIONID%/resourceGroups/%RESOURCEGROUPNAME%/providers/Microsoft.Network/virtualNetworks/%VNETNAME%/subnets/%REDISSUBNETNAME%
REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

if %REDISSKU%==Premium ECHO Creating a specific subnet named %REDISSUBNETNAME% for the redis cache, within the virtual network %VNETNAME% & CALL az network vnet subnet create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --vnet-name %VNETNAME% ^
 --name %REDISSUBNETNAME% ^
 --address-prefixes %REDISSUBNETADDRESSPREFIX%

if %REDISSKU%==Premium ECHO Creating a %REDISSKU% %REDISVMSIZE% Redis Cache named %REDISNAMEUNIQUE% with %REDISSHARDSTOCREATE% shards within the subnet %SUBNETID% & CALL az redis create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAMEUNIQUE% ^
 --location %REGIONNAME% ^
 --sku %REDISSKU% ^
 --vm-size %REDISVMSIZE% ^
 --shard-count %REDISSHARDSTOCREATE% ^
 --subnet-id %SUBNETID%

if %REDISSKU%==Standard ECHO Creating a %REDISSKU% %REDISVMSIZE% Redis Cache named %REDISNAMEUNIQUE% & CALL az redis create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAMEUNIQUE% ^
 --location %REGIONNAME% ^
 --sku %REDISSKU% ^
 --vm-size %REDISVMSIZE%

if %REDISSKU%==Basic ECHO Creating a %REDISSKU% %REDISVMSIZE% Redis Cache named %REDISNAME% & CALL az redis create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAMEUNIQUE% ^
 --location %REGIONNAME% ^
 --sku %REDISSKU% ^
 --vm-size %REDISVMSIZE%

ECHO Showing details of the cache named %RESOURCEGROUPNAME% (hostName, enableNonSslPort, port, sslPort, primaryKey and secondaryKey)
CALL az redis show ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAMEUNIQUE% ^
 --query [hostName,enableNonSslPort,port,sslPort] ^
 --output tsv

CALL az redis list-keys ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAMEUNIQUE% ^
 --query [primaryKey,secondaryKey] ^
 --output tsv
