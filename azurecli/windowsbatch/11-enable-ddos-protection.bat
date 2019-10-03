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
SET PREFIX=myGameBackend

REM # Variables for creating the DDoS Standard Protection plan
SET VNETNAME=%PREFIX%VNET
SET DDOSPROTECTIONNAME=%PREFIX%DdosPlan
REM #############################################################################################

REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Creating the DDoS Protection plan named %GOLDENIMAGENAME% protecting the Virtual Network %VMNAME%
CALL az network ddos-protection create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %DDOSPROTECTIONNAME% ^
 --vnets %VNETNAME%

ECHO Enabling the DDoS Standard plan on the Virtual Network
CALL az network vnet update ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VNETNAME% ^
 --ddos-protection true ^
 --ddos-protection-plan %DDOSPROTECTIONNAME%
