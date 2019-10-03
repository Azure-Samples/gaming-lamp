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
export LOGINUSERNAME=azureuser
export PREFIX=myGameBackend

export VNETNAME=${PREFIX}VNET

# Variables for setting up the MySQL database
export MYSQLNAME=${PREFIX}MySQL
export MYSQLUSERNAME=azuremysqluser
export MYSQLPASSWORD=CHang3thisP4Ssw0rD
export MYSQLDBNAME=gamedb
export MYSQLBACKUPRETAINEDDAYS=7
export MYSQLGEOREDUNDANTBACKUP=Disabled
export MYSQLSKU=GP_Gen5_2
export MYSQLSTORAGEMBSIZE=51200
export MYSQLVERSION=5.7
export MYSQLREADREPLICANAME=${MYSQLNAME}Replica
export MYSQLREADREPLICAREGION=japanwest
export MYSQLSUBNETNAME=${MYSQLNAME}Subnet
export MYSQLSUBNETADDRESSPREFIX=10.0.2.0/24
export MYSQLRULENAME=${MYSQLNAME}Rule
#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

# Enable Azure CLI db-up extension (in preview)
az extension add --name db-up

echo In addition to creating the server, the az mysql up command creates a sample database, a root user in the database, opens the firewall for Azure services, and creates default firewall rules for the client computer
az mysql up \
 --resource-group $RESOURCEGROUPNAME \
 --server-name $MYSQLNAME \
 --admin-user $MYSQLUSERNAME \
 --admin-password $MYSQLPASSWORD \
 --backup-retention $MYSQLBACKUPRETAINEDDAYS \
 --database-name $MYSQLDBNAME \
 --geo-redundant-backup $MYSQLGEOREDUNDANTBACKUP \
 --location $REGIONNAME \
 --sku-name $MYSQLSKU \
 --storage-size $MYSQLSTORAGEMBSIZE \
 --version=$MYSQLVERSION

echo Creating and enabling Azure Database for MySQL Virtual Network service endpoints
az network vnet subnet create \
 --resource-group $RESOURCEGROUPNAME \
 --vnet-name $VNETNAME \
 --name $MYSQLSUBNETNAME \
 --service-endpoints Microsoft.SQL \
 --address-prefix $MYSQLSUBNETADDRESSPREFIX

echo Creating a Virtual Network rule on the MySQL server to secure it to the subnet
az mysql server vnet-rule create \
 --resource-group $RESOURCEGROUPNAME \
 --server-name $MYSQLNAME \
 --vnet-name $VNETNAME \
 --subnet $MYSQLSUBNETNAME \
 --name $MYSQLRULENAME

echo creating a read replica named $MYSQLREADREPLICANAME in the region $MYSQLREADREPLICAREGION using $MYSQLNAME as a source - master
az mysql server replica create \
 --resource-group $RESOURCEGROUPNAME \
 --name $MYSQLREADREPLICANAME \
 --source-server $MYSQLNAME \
 --location $MYSQLREADREPLICAREGION
