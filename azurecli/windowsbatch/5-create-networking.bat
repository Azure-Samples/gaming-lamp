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
SET PREFIX=myGameBackend

REM # Variables for creating the networking resources (load balancer, etc)
SET LBSKU=Basic
SET PUBLICIPNAME=%PREFIX%PublicIP
SET PUBLICIPALLOCATION=Static
SET PUBLICIPVERSION=IPv4
SET LBNAME=%PREFIX%LB
SET VNETNAME=%PREFIX%VNET
SET VNETADDRESSPREFIX=10.0.0.0/16
SET SUBNETNAME=%PREFIX%Subnet
SET SUBNETADDRESSPREFIX=10.0.0.0/24
SET LBBEPOOLNAME=%LBNAME%BEPool
SET LBFENAME=%LBNAME%FE
SET LBFEPORTRANGESTART=50000
SET LBFEPORTRANGEEND=50119
SET LBNATPOOLNAME=%LBNAME%NATPool
SET LBRULEHTTPNAME=%LBNAME%HTTPRule
SET LBRULEHTTPSNAME=%LBNAME%HTTPSRule
REM #############################################################################################

REM #############################################################################################

REM # Connect to Azure
CALL az login

REM # Set the Azure subscription
CALL az account set --subscription %YOURSUBSCRIPTIONID%

ECHO Creating a virtual network named %VNETNAME% and a subnet named %SUBNETNAME%
CALL az network vnet create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %VNETNAME% ^
 --address-prefix %VNETADDRESSPREFIX% ^
 --subnet-name %SUBNETNAME% ^
 --subnet-prefix %SUBNETADDRESSPREFIX%

ECHO Creating an inbound public IP address for the load balancer named %PUBLICIPNAME%
CALL az network public-ip create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %PUBLICIPNAME% ^
 --allocation-method %PUBLICIPALLOCATION% ^
 --sku %LBSKU% ^
 --version %PUBLICIPVERSION%

ECHO Creating a load balancer named %LBNAME%
CALL az network lb create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %LBNAME% ^
 --sku %LBSKU% ^
 --backend-pool-name %LBBEPOOLNAME% ^
 --frontend-ip-name %LBFENAME% ^
 --public-ip-address %PUBLICIPNAME%

ECHO Creating the load balancer health probe for HTTP
CALL az network lb probe create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --lb-name %LBNAME% ^
 --name http ^
 --protocol http ^
 --port 80 ^
 --path /

if %LBSKU%==Standard ECHO Creating the load balancer health probe for HTTPs (Standard Load Balancer SKU only) & CALL az network lb probe create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --lb-name %LBNAME% ^
 --name https ^
 --protocol https ^
 --port 443 ^
 --path /

ECHO Create an inbound NAT pool with backend port 22
CALL az network lb inbound-nat-pool create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %LBNATPOOLNAME% ^
 --backend-port 22 ^
 --frontend-port-range-start %LBFEPORTRANGESTART% ^
 --frontend-port-range-end %LBFEPORTRANGEEND% ^
 --lb-name %LBNAME% ^
 --frontend-ip-name %LBFENAME% ^
 --protocol Tcp

ECHO Creating a load balancing inbound rule for the port 80
CALL az network lb rule create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %LBRULEHTTPNAME% ^
 --lb-name %LBNAME% ^
 --protocol tcp ^
 --frontend-port 80 ^
 --backend-port 80 ^
 --probe http ^
 --frontend-ip-name %LBFENAME% ^
 --backend-pool-name %LBBEPOOLNAME%

if %LBSKU%==Standard ECHO Creating a load balancing inbound rule for the port 443 (Standard Load Balancer SKU only) & CALL az network lb rule create ^
 --resource-group %RESOURCEGROUPNAME% ^
 --name %LBRULEHTTPSNAME% ^
 --lb-name %LBNAME% ^
 --protocol tcp ^
 --frontend-port 443 ^
 --backend-port 443 ^
 --probe https ^
 --frontend-ip-name %LBFENAME% ^
 --backend-pool-name %LBBEPOOLNAME%
