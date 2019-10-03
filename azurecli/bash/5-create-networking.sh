#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Ensure that you have a golden image ready prior to creating the virtual machine scale set
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export RESOURCEGROUPNAME=myResourceGroup
export REGIONNAME=japaneast
export PREFIX=myGameBackend

# Variables for creating the networking resources (load balancer, etc)
export LBSKU=Basic
export PUBLICIPNAME=${PREFIX}PublicIP
export PUBLICIPALLOCATION=Static
export PUBLICIPVERSION=IPv4
export LBNAME=${PREFIX}LB
export VNETNAME=${PREFIX}VNET
export VNETADDRESSPREFIX=10.0.0.0/16
export SUBNETNAME=${PREFIX}Subnet
export SUBNETADDRESSPREFIX=10.0.0.0/24
export LBBEPOOLNAME=${LBNAME}BEPool
export LBFENAME=${LBNAME}FE
export LBFEPORTRANGESTART=50000
export LBFEPORTRANGEEND=50119
export LBNATPOOLNAME=${LBNAME}NATPool
export LBRULEHTTPNAME=${LBNAME}HTTPRule
export LBRULEHTTPSNAME=${LBNAME}HTTPSRule
#############################################################################################

#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Creating a virtual network named $VNETNAME and a subnet named $SUBNETNAME
az network vnet create \
 --resource-group $RESOURCEGROUPNAME \
 --name $VNETNAME \
 --address-prefix $VNETADDRESSPREFIX \
 --subnet-name $SUBNETNAME \
 --subnet-prefix $SUBNETADDRESSPREFIX

echo Creating an inbound public IP address for the load balancer named $PUBLICIPNAME
az network public-ip create \
 --resource-group $RESOURCEGROUPNAME \
 --name $PUBLICIPNAME \
 --allocation-method $PUBLICIPALLOCATION \
 --sku $LBSKU \
 --version $PUBLICIPVERSION

echo Creating a load balancer named $LBNAME
az network lb create \
 --resource-group $RESOURCEGROUPNAME \
 --name $LBNAME \
 --sku $LBSKU \
 --backend-pool-name $LBBEPOOLNAME \
 --frontend-ip-name $LBFENAME \
 --public-ip-address $PUBLICIPNAME

echo Creating the load balancer health probe for HTTP
az network lb probe create \
 --resource-group $RESOURCEGROUPNAME \
 --lb-name $LBNAME \
 --name http \
 --protocol http \
 --port 80 \
 --path /

if [ "$LBSKU" = "Standard" ]; then
echo Creating the load balancer health probe for HTTPs (Standard Load Balancer SKU only)
az network lb probe create \
 --resource-group $RESOURCEGROUPNAME \
 --lb-name $LBNAME \
 --name https \
 --protocol https \
 --port 443 \
 --path /
fi

echo Create an inbound NAT pool with backend port 22
az network lb inbound-nat-pool create \
 --resource-group $RESOURCEGROUPNAME \
 --name $LBNATPOOLNAME \
 --backend-port 22 \
 --frontend-port-range-start $LBFEPORTRANGESTART \
 --frontend-port-range-end $LBFEPORTRANGEEND \
 --lb-name $LBNAME \
 --frontend-ip-name $LBFENAME \
 --protocol Tcp

echo Creating a load balancing inbound rule for the port 80
az network lb rule create \
 --resource-group $RESOURCEGROUPNAME \
 --name $LBRULEHTTPNAME \
 --lb-name $LBNAME \
 --protocol tcp \
 --frontend-port 80 \
 --backend-port 80 \
 --probe http \
 --frontend-ip-name $LBFENAME \
 --backend-pool-name $LBBEPOOLNAME

if [ "$LBSKU" = "Standard" ]; then
echo Creating a load balancing inbound rule for the port 443 (Standard Load Balancer SKU only)
az network lb rule create \
 --resource-group $RESOURCEGROUPNAME \
 --name $LBRULEHTTPSNAME \
 --lb-name $LBNAME \
 --protocol tcp \
 --frontend-port 443 \
 --backend-port 443 \
 --probe https \
 --frontend-ip-name $LBFENAME \
 --backend-pool-name $LBBEPOOLNAME
fi
