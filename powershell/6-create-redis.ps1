# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$RANDOMNUMBER=Get-Random
$REDISNAME=$PREFIX+'Redis'
$REDISNAMEUNIQUE=$REDISNAME+$RANDOMNUMBER
$REDISVMSIZE='C1'
$REDISSKU='Standard'
$REDISSHARDSTOCREATE=2
$VNETNAME=$PREFIX+'VNET'
$REDISSUBNETNAME=$REDISNAME+'Subnet'
$REDISSUBNETADDRESSPREFIX='10.0.1.0/24'
$SUBNETID='/subscriptions/'+$YOURSUBSCRIPTIONID+'/resourceGroups/'+$RESOURCEGROUPNAME+'/providers/Microsoft.Network/virtualNetworks/'+$VNETNAME+'/subnets/'+$REDISSUBNETNAME

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create a specific subnet named cache
$vnet = Get-AzVirtualNetwork `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VNETNAME

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
 -Name $REDISSUBNETNAME `
 -AddressPrefix $REDISSUBNETADDRESSPREFIX `
 -VirtualNetwork $vnet

$vnet | Set-AzVirtualNetwork

# Create an Azure Cache for Redis
if($REDISSKU -eq "Standard") {
 New-AzRedisCache `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $REDISNAMEUNIQUE `
 -Location $REGIONNAME `
 -Size $REDISVMSIZE `
 -Sku $REDISSKU `
 -RedisConfiguration @{"maxmemory-policy" = "allkeys-random"}
}

if($REDISSKU -eq "Premium") {
 New-AzRedisCache `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $REDISNAMEUNIQUE `
 -Location $REGIONNAME `
 -Size $REDISVMSIZE `
 -Sku $REDISSKU `
 -RedisConfiguration @{"maxmemory-policy" = "allkeys-random"} `
 -ShardCount $REDISSHARDSTOCREATE `
 -SubnetId $SUBNETID
}

# Get details of the cache (hostName, enableNonSslPort, port, sslPort, primaryKey and secondaryKey)
Get-AzRedisCache `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $REDISNAMEUNIQUE | Select-Object HostName, EnableNonSslPort, Port, SslPort

Get-AzRedisCacheKey `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $REDISNAMEUNIQUE
