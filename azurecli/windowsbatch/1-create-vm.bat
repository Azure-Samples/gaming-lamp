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
SET LOGINUSERNAME=azureuser
REM #SET LOGINPASSWORD=N0tReCoMM3ND3DUseSSH

REM # Variables for creating the VM that will serve as a foundation for the VMSS golden image
SET VMNAME=myVirtualMachine
SET IMAGE=Canonical:UbuntuServer:16.04-LTS:latest
SET VMSIZE=Standard_B1s
SET VMDATADISKSIZEINGB=5
REM #############################################################################################

REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

REM # Create a resource group
ECHO Creating resource group named %RESOURCEGROUPNAME% in region %REGIONNAME% 
CALL az group create ^
 --name %RESOURCEGROUPNAME% ^
 --location %REGIONNAME%

REM # Create a virtual machine
ECHO Creating a virtual machine named %VMNAME% with size %VMSIZE% - it will take a few minutes
CALL az vm create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMNAME% ^
 --image %IMAGE% ^
 --size %VMSIZE% ^
 --admin-username %LOGINUSERNAME% ^
 --data-disk-sizes-gb %VMDATADISKSIZEINGB% ^
 --generate-ssh-keys

REM # Open the port 80
ECHO Opening port 80 in the virtual machine named %VMNAME%
CALL az vm open-port ^
 --port 80 ^
 --priority 900 ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMNAME%

REM # Open the port 443
ECHO Opening port 443 in the virtual machine named %VMNAME%
CALL az vm open-port ^
 --port 443 ^
 --priority 901 ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMNAME%
