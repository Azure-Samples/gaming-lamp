#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# All redis cache need to have a unique name across Azure, so you can't use a common name like myRedis
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export RESOURCEGROUPNAME=myResourceGroup
export REGIONNAME=japanwest
export PREFIX=myGameBackend

# Variables for setting up the redis cache
export RANDOMNUMBER=`head -200 /dev/urandom | cksum | cut -f2 -d " "`
export REDISNAME=${PREFIX}Redis
export REDISNAMEUNIQUE=${REDISNAME}${RANDOMNUMBER}
export REDISVMSIZE=C1
export REDISSKU=Standard
export REDISSHARDSTOCREATE=2
export VNETNAME=${PREFIX}VNET
export REDISSUBNETNAME=${REDISNAME}Subnet
export REDISSUBNETADDRESSPREFIX=10.0.1.0/24
export SUBNETID=/subscriptions/${YOURSUBSCRIPTIONID}/resourceGroups/${RESOURCEGROUPNAME}/providers/Microsoft.Network/virtualNetworks/${VNETNAME}/subnets/${REDISSUBNETNAME}
#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

if [ "$REDISSKU" = "Premium" ]; then
echo Creating a specific subnet named $REDISSUBNETNAME for the redis cache, within the virtual network $VNETNAME
az network vnet subnet create \
 --resource-group $RESOURCEGROUPNAME \
 --vnet-name $VNETNAME \
 --name $REDISSUBNETNAME \
 --address-prefixes $REDISSUBNETADDRESSPREFIX
fi

if [ "$REDISSKU" = "Premium" ]; then
echo Creating a $REDISSKU $REDISVMSIZE Redis Cache named $REDISNAMEUNIQUE with $REDISSHARDSTOCREATE shards within the subnet $SUBNETID
az redis create \
 --resource-group $RESOURCEGROUPNAME \
 --name $REDISNAMEUNIQUE \
 --location $REGIONNAME \
 --sku $REDISSKU \
 --vm-size $REDISVMSIZE \
 --shard-count $REDISSHARDSTOCREATE \
 --subnet-id $SUBNETID
fi

if [ "$REDISSKU" = "Standard" ]; then
echo Creating a $REDISSKU $REDISVMSIZE Redis Cache named $REDISNAMEUNIQUE
az redis create \
 --resource-group $RESOURCEGROUPNAME \
 --name $REDISNAMEUNIQUE \
 --location $REGIONNAME \
 --sku $REDISSKU \
 --vm-size $REDISVMSIZE
fi

if [ "$REDISSKU" = "Basic" ]; then
echo Creating a $REDISSKU $REDISVMSIZE Redis Cache named $REDISNAMEUNIQUE
az redis create \
 --resource-group $RESOURCEGROUPNAME \
 --name $REDISNAMEUNIQUE \
 --location $REGIONNAME \
 --sku $REDISSKU \
 --vm-size $REDISVMSIZE
fi

echo Showing details of the cache named $RESOURCEGROUPNAME - hostName, enableNonSslPort, port, sslPort, primaryKey and secondaryKey
az redis show \
 --resource-group $RESOURCEGROUPNAME \
 --name $REDISNAMEUNIQUE \
 --query [hostName,enableNonSslPort,port,sslPort] \
 --output tsv

az redis list-keys \
 --resource-group $RESOURCEGROUPNAME \
 --name $REDISNAMEUNIQUE \
 --query [primaryKey,secondaryKey] \
 --output tsv
