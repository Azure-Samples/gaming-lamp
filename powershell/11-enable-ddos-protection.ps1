# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$VNETNAME=$PREFIX+'VNET'
$DDOSPROTECTIONNAME=$PREFIX+'DdosPlan'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create the DDoS protection plan
$ddosProtectionPlan = New-AzDdosProtectionPlan `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $DDOSPROTECTIONNAME `
 -Location $REGIONNAME

# Enable the DDoS Standard plan on the Virtual Network
$vnet = Get-AzVirtualNetwork -Name $VNETNAME -ResourceGroupName $RESOURCEGROUPNAME
$vnet.DdosProtectionPlan = New-Object Microsoft.Azure.Commands.Network.Models.PSResourceId
$vnet.DdosProtectionPlan.Id = $ddosProtectionPlan.Id
$vnet.EnableDdosProtection = $True
$vnet | Set-AzVirtualNetwork
