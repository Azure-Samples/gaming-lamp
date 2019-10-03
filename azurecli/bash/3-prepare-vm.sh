#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Ensure that you have installed in the virtual machine all you need prior to creating the image
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export RESOURCEGROUPNAME=myResourceGroup
export REGIONNAME=japaneast

# Variables for preparing the Virtual Machine
export VMNAME=myVirtualMachine
#############################################################################################

#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Stopping and deallocating the virtual machine named $VMNAME
az vm deallocate \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMNAME

echo Generalizing the virtual machine named $VMNAME
az vm generalize \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMNAME
