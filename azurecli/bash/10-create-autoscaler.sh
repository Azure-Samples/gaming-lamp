#!/bin/bash
#############################################################################################
# Ensure you have logged in to Azure with your credentials prior to running this script
# az login

# Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
# "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Ensure that you have a virtual machine scale set already in place
#############################################################################################

#############################################################################################
# General variables used in the different Azure CLI commands run from this script
export YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export RESOURCEGROUPNAME=myResourceGroup
export REGIONNAME=japaneast
export PREFIX=myGameBackend

# Variables for setting up the virtual machine scale set autoscaler
export VMSSNAME=%PREFIX%VMSS
export VMSSVMTOCREATE=2
export VMSSAUTOSCALERNAME=${PREFIX}Autoscaler
export VMSSAUTOSCALERCRITERIA=Percentage CPU
export VMSSAUTOSCALERMAXCOUNT=10
export VMSSAUTOSCALERMINCOUNT=$VMSSVMTOCREATE
export VMSSAUTOSCALERUPTRIGGER=50 avg 5m
export VMSSAUTOSCALERDOWNTRIGGER=30 avg 5m
export VMSSAUTOSCALEROUTINCREASE=1
export VMSSAUTOSCALERINDECREASE=1
#############################################################################################

# Connect to Azure
az login

# Set the Azure subscription
az account set \
 --subscription $YOURSUBSCRIPTIONID

echo Defining the autoscaling profile
az monitor autoscale create \
 --resource-group $RESOURCEGROUPNAME \
 --resource $VMSSNAME \
 --resource-type Microsoft.Compute/virtualMachineScaleSets \
 --name $VMSSAUTOSCALERNAME \
 --min-count $VMSSAUTOSCALERMINCOUNT \
 --max-count $VMSSAUTOSCALERMAXCOUNT \
 --count $VMSSVMTOCREATE

echo Enabling virtual machine autoscaler for scaling out
az monitor autoscale rule create \
 --resource-group $RESOURCEGROUPNAME \
 --autoscale-name $VMSSAUTOSCALERNAME \
 --condition "${VMSSAUTOSCALERCRITERIA} > ${VMSSAUTOSCALERUPTRIGGER}" \
 --scale out $VMSSAUTOSCALEROUTINCREASE

echo Enabling virtual machine autoscaler for scaling in
az monitor autoscale rule create \
 --resource-group $RESOURCEGROUPNAME \
 --autoscale-name $VMSSAUTOSCALERNAME \
 --condition "${VMSSAUTOSCALERCRITERIA} < ${VMSSAUTOSCALERDOWNTRIGGER}" \
 --scale in $VMSSAUTOSCALERINDECREASE
