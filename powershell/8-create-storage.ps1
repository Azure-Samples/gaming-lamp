# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$VNETNAME=$PREFIX+'VNET'
$RANDOMNUMBER=Get-Random -Max 10000
$STORAGENAME=$PREFIX+'STRG'
$STORAGENAMELOWER=$STORAGENAME.tolower()
$STORAGENAMEUNIQUE=$STORAGENAMELOWER+$RANDOMNUMBER
$STORAGESKU='Standard_LRS'
$STORAGECONTAINERNAME=$STORAGENAMELOWER+'cntnr'
$STORAGESUBNETNAME=$STORAGENAME+'Subnet'
$STORAGESUBNETADDRESSPREFIX='10.0.3.0/24'
$STORAGERULENAME=$STORAGENAME+'Rule'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create a storage account
New-AzStorageAccount `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $STORAGENAMEUNIQUE `
 -SkuName $STORAGESKU `
 -Location $REGIONNAME

# Create a storage container into the storage account
$accountObject = Get-AzStorageAccount `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -AccountName $STORAGENAMEUNIQUE

New-AzRmStorageContainer `
 -StorageAccount $accountObject `
 -ContainerName $STORAGECONTAINERNAME

# Enable service endpoint for Azure Storage on the Virtual Network and subnet
$vnet = Get-AzVirtualNetwork `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VNETNAME

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
 -Name $STORAGESUBNETNAME `
 -AddressPrefix $STORAGESUBNETADDRESSPREFIX `
 -VirtualNetwork $vnet `
 -ServiceEndpoint Microsoft.Storage

$vnet | Set-AzVirtualNetwork

# Add a network rule for a virtual network and subnet
$subnetId = $vnet.Id + '/subnets/' + $STORAGESUBNETNAME

Add-AzStorageAccountNetworkRule `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $STORAGENAMEUNIQUE `
 -VirtualNetworkResourceId $subnetId
