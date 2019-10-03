@echo off
REM #############################################################################################
REM # Ensure you have logged in to Azure with your credentials prior to running this script
REM # az login

REM # Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
REM # "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

REM # Ensure that you have a golden image ready prior to creating the virtual machine scale set
REM #############################################################################################

REM #############################################################################################
REM # General variables used in the different Azure CLI commands run from this script
SET YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
SET RESOURCEGROUPNAME=myResourceGroup
SET REGIONNAME=japanwest
SET LOGINUSERNAME=azureuser
REM #SET LOGINPASSWORD=N0tReCoMM3ND3DUseSSH
SET PREFIX=myGameBackend

REM # Variables for referencing the networking resources (load balancer, etc) needed to create the scale set
SET LBNAME=%PREFIX%LB
SET LBSKU=Basic
SET VNETNAME=%PREFIX%VNET
SET SUBNETNAME=%PREFIX%Subnet
SET LBBEPOOLNAME=%LBNAME%BEPool
SET LBFENAME=%LBNAME%FE
SET LBNATPOOLNAME=%LBNAME%NATPool

REM # Variables for setting up the virtual machine scale set
SET VMSSNAME=%PREFIX%VMSS
SET GOLDENIMAGENAME=myGoldenImage
SET VMSSSKUSIZE=Standard_B1s
SET VMSSVMTOCREATE=2
SET VMSSSTORAGETYPE=Premium_LRS
SET VMSSACELERATEDNETWORKING=false
SET VMSSUPGRADEPOLICY=Manual
SET HEALTHPROBEID=/subscriptions/%YOURSUBSCRIPTIONID%/resourceGroups/%RESOURCEGROUPNAME%/providers/Microsoft.Network/loadBalancers/%LBNAME%/probes/http
REM # SET the following variable to empty if you want to enable overprovision for faster deployment
SET VMSSOVERPROVISIONING=--disable-overprovision
REM #############################################################################################

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Creating a virtual machine scale set named %VMSSNAME%
CALL az vmss create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMSSNAME% ^
 --image %GOLDENIMAGENAME% ^
 --upgrade-policy-mode %VMSSUPGRADEPOLICY% ^
 --load-balancer %LBNAME% ^
 --lb-sku %LBSKU% ^
 --vnet-name %VNETNAME% ^
 --subnet %SUBNETNAME% ^
 --admin-username %LOGINUSERNAME% ^
 --instance-count %VMSSVMTOCREATE% ^
 --backend-pool-name %LBBEPOOLNAME% ^
 --storage-sku %VMSSSTORAGETYPE% ^
 --vm-sku %VMSSSKUSIZE% ^
 --lb-nat-pool-name %LBNATPOOLNAME% ^
 --accelerated-networking %VMSSACELERATEDNETWORKING% ^
 --generate-ssh-keys %VMSSOVERPROVISIONING%

ECHO Scale set upgrade policy
CALL az vmss show ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMSSNAME% ^
 --query upgradePolicy

ECHO Associating the load balancer health probe to the scale set
CALL az vmss update ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMSSNAME% ^
 --query virtualMachineProfile.networkProfile.healthProbe ^
 --set virtualMachineProfile.networkProfile.healthProbe.id='%HEALTHPROBEID%'

ECHO Updating all the instances
CALL az vmss update-instances ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMSSNAME% ^
 --instance-ids *

ECHO Switching to Rolling upgrade mode
CALL az vmss update ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMSSNAME% ^
 --query upgradePolicy ^
 --set upgradePolicy.mode=Rolling
