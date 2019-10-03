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

SET VNETNAME=%PREFIX%VNET

REM # Variables for setting up the MySQL database
SET MYSQLNAME=%PREFIX%MySQL
SET MYSQLUSERNAME=azuremysqluser
SET MYSQLPASSWORD=CHang3thisP4Ssw0rD
SET MYSQLDBNAME=gamedb
SET MYSQLBACKUPRETAINEDDAYS=7
SET MYSQLGEOREDUNDANTBACKUP=Disabled
SET MYSQLSKU=GP_Gen5_2
SET MYSQLSTORAGEMBSIZE=51200
SET MYSQLVERSION=5.7
SET MYSQLSUBNETNAME=%MYSQLNAME%Subnet
SET MYSQLSUBNETADDRESSPREFIX=10.0.2.0/24
SET MYSQLRULENAME=%MYSQLNAME%Rule

REM # Variables for setting up the read replicas
SET MYSQLREADREPLICANAME=%MYSQLNAME%Replica
SET MYSQLREADREPLICAREGION=japanwest
REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

REM # Enable Azure CLI db-up extension (in preview)
CALL az extension add --name db-up

ECHO In addition to creating the server, the az mysql up command creates a sample database, a root user in the database, opens the firewall for Azure services, and creates default firewall rules for the client computer
CALL az mysql up ^
 --resource-group %RESOURCEGROUPNAME% ^
 --server-name %MYSQLNAME% ^
 --admin-user %MYSQLUSERNAME% ^
 --admin-password %MYSQLPASSWORD% ^
 --backup-retention %MYSQLBACKUPRETAINEDDAYS% ^
 --database-name %MYSQLDBNAME% ^
 --geo-redundant-backup %MYSQLGEOREDUNDANTBACKUP% ^
 --location %REGIONNAME% ^
 --sku-name %MYSQLSKU% ^
 --storage-size %MYSQLSTORAGEMBSIZE% ^
 --version=%MYSQLVERSION%

ECHO Creating and enabling Azure Database for MySQL Virtual Network service endpoints
CALL az network vnet subnet create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --vnet-name %VNETNAME% ^
 --name %MYSQLSUBNETNAME% ^
 --service-endpoints Microsoft.SQL ^
 --address-prefix %MYSQLSUBNETADDRESSPREFIX%

ECHO Creating a Virtual Network rule on the MySQL server to secure it to the subnet
CALL az mysql server vnet-rule create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --server-name %MYSQLNAME% ^
 --vnet-name %VNETNAME% ^
 --subnet %MYSQLSUBNETNAME% ^
 --name %MYSQLRULENAME%

Echo creating a read replica named %MYSQLREADREPLICANAME% in the region %MYSQLREADREPLICAREGION% using %MYSQLNAME% as a source (master)
CALL az mysql server replica create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %MYSQLREADREPLICANAME% ^
 --source-server %MYSQLNAME% ^
 --location %MYSQLREADREPLICAREGION%
