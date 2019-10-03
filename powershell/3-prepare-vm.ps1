# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'
$VMNAME='myVirtualMachine'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Stop and deallocate the Azure Virtual Machine
Stop-AzVM `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VMNAME `
 -Force

# Generalize the Azure Virtual Machine
Set-AzVM `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VMNAME `
 -Generalized
