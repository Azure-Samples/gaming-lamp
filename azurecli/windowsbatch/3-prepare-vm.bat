@echo off
REM #############################################################################################
REM # Ensure you have logged in to Azure with your credentials prior to running this script
REM # az login

REM # Ensure that you have the Azure subscription ID, it should show up after you have logged in and it has the format:
REM # "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

REM # Ensure that you have installed in the virtual machine all you need prior to creating the image
REM #############################################################################################

REM #############################################################################################
REM # General variables used in the different Azure CLI commands run from this script
SET YOURSUBSCRIPTIONID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
SET RESOURCEGROUPNAME=myResourceGroup
SET REGIONNAME=japanwest

REM # Variables for preparing the Virtual Machine
SET VMNAME=myVirtualMachine
REM #############################################################################################

REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Stopping and deallocating the virtual machine named %VMNAME%
CALL az vm deallocate ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMNAME%

ECHO Generalizing the virtual machine named %VMNAME%
CALL az vm generalize ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VMNAME%
