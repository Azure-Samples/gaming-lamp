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

# Variables for creating the DDoS Standard Protection plan
export VNETNAME=${PREFIX}VNET
export DDOSPROTECTIONNAME=${PREFIX}DdosPlan
#############################################################################################

#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Creating the DDoS Protection plan named $GOLDENIMAGENAME protecting the Virtual Network $VMNAME
az network ddos-protection create \
 --resource-group $RESOURCEGROUPNAME \
 --name $DDOSPROTECTIONNAME \
 --vnets $VNETNAME

echo Enabling the DDoS Standard plan on the Virtual Network
az network vnet update \
 --resource-group $RESOURCEGROUPNAME \
 --name $VNETNAME \
 --ddos-protection true \
 --ddos-protection-plan $DDOSPROTECTIONNAME
