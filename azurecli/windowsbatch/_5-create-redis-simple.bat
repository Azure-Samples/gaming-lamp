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
SET REGIONNAME=japaneast
SET PREFIX=myGameBackend

REM # Variables for setting up the redis cache
SET REDISNAME=%PREFIX%Redis
SET REDISNAMEUNIQUE=%REDISNAME%%RANDOM%
SET REDISVMSIZE=C1
SET REDISSKU=Standard
REM #############################################################################################

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Creating a %REDISSKU% %REDISVMSIZE% Redis Cache named %REDISNAME%
CALL az redis create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAME% ^
 --location %REGIONNAME% ^
 --sku %REDISSKU% ^
 --vm-size %REDISVMSIZE%

ECHO Showing details of the cache named %REDISNAME% (hostName, enableNonSslPort, port, sslPort)
CALL az redis show ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAME% ^
 --query [hostName,enableNonSslPort,port,sslPort] ^
 --output tsv

CALL az redis list-keys ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %REDISNAME% ^
 --query [primaryKey,secondaryKey] ^
 --output tsv
