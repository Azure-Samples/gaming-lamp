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
export LOGINUSERNAME=azureuser
#export LOGINPASSWORD=N0tReCoMM3ND3DUseSSH
export PREFIX=myGameBackend

# Variables for referencing the networking resources (load balancer, etc) needed to create the scale set
export LBNAME=${PREFIX}LB
export LBSKU=Standard
export VNETNAME=${PREFIX}VNET
export SUBNETNAME=${PREFIX}Subnet
export LBBEPOOLNAME=${LBNAME}BEPool
export LBFENAME=${LBNAME}FE
export LBNATPOOLNAME=${LBNAME}NATPool

# Variables for setting up the virtual machine scale set
export VMSSNAME=${PREFIX}VMSS
export GOLDENIMAGENAME=myGoldenImage
export VMSSSKUSIZE=Standard_B1s
export VMSSVMTOCREATE=2
export VMSSSTORAGETYPE=Premium_LRS
export VMSSACELERATEDNETWORKING=false
export VMSSUPGRADEPOLICY=Manual
export HEALTHPROBEID=/subscriptions/${YOURSUBSCRIPTIONID}/resourceGroups/${RESOURCEGROUPNAME}/providers/Microsoft.Network/loadBalancers/${LBNAME}/probes/http
export VMSSOVERPROVISIONING=--disable-overprovision
#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Creating a virtual machine scale set named $VMSSNAME
az vmss create \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMSSNAME \
 --image $GOLDENIMAGENAME \
 --upgrade-policy-mode $VMSSUPGRADEPOLICY \
 --load-balancer $LBNAME \
 --lb-sku $LBSKU \
 --vnet-name $VNETNAME \
 --subnet $SUBNETNAME \
 --admin-username $LOGINUSERNAME \
 --instance-count $VMSSVMTOCREATE \
 --backend-pool-name $LBBEPOOLNAME \
 --storage-sku $VMSSSTORAGETYPE \
 --vm-sku $VMSSSKUSIZE \
 --lb-nat-pool-name $LBNATPOOLNAME \
 --accelerated-networking $VMSSACELERATEDNETWORKING \
 --generate-ssh-keys $VMSSOVERPROVISIONING

echo Scale set upgrade policy
az vmss show \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMSSNAME \
 --query upgradePolicy

echo Associating the load balancer health probe to the scale set
az vmss update \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMSSNAME \
 --query virtualMachineProfile.networkProfile.healthProbe \
 --set virtualMachineProfile.networkProfile.healthProbe.id='${HEALTHPROBEID}'

echo Updating all the instances
az vmss update-instances \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMSSNAME \
 --instance-ids *

echo Switching to Rolling upgrade mode
az vmss update \
 --resource-group $RESOURCEGROUPNAME \
 --name $VMSSNAME \
 --query upgradePolicy \
 --set upgradePolicy.mode=Rolling
