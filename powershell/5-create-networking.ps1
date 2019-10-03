# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$LBSKU='Basic'
$PUBLICIPNAME=$PREFIX+'PublicIP'
$PUBLICIPALLOCATION='Static'
$PUBLICIPVERSION='IPv4'
$LBNAME=$PREFIX+'LB'
$VNETNAME=$PREFIX+'VNET'
$VNETADDRESSPREFIX='10.0.0.0/16'
$SUBNETNAME=$PREFIX+'Subnet'
$SUBNETADDRESSPREFIX='10.0.0.0/24'
$LBBEPOOLNAME=$LBNAME+'BEPool'
$LBFENAME=$LBNAME+'FE'
$LBFEPORTRANGESTART=50000
$LBFEPORTRANGEEND=50119
$LBNATPOOLNAME=$LBNAME+'NATPool'
$LBRULEHTTPNAME=$LBNAME+'HTTPRule'
$LBRULEHTTPSNAME=$LBNAME+'HTTPSRule'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create the Azure Virtual Network
$vnet = New-AzVirtualNetwork `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VNETNAME `
 -Location $REGIONNAME `
 -AddressPrefix $VNETADDRESSPREFIX

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
 -Name $SUBNETNAME `
 -AddressPrefix $SUBNETADDRESSPREFIX `
 -VirtualNetwork $vnet

$vnet | Set-AzVirtualNetwork

# Create an inbound public IP address for the load balancer
$publicIp = New-AzPublicIpAddress `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $PUBLICIPNAME `
 -Location $REGIONNAME `
 -AllocationMethod $PUBLICIPALLOCATION `
 -IpAddressVersion $PUBLICIPVERSION `
 -Sku $LBSKU

# Create an Azure Load Balancer
New-AzLoadBalancer `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $LBNAME `
 -Location $REGIONNAME `
 -Sku $LBSKU

$lb = Get-AzLoadBalancer -ResourceGroupName $RESOURCEGROUPNAME -Name $LBNAME

$lb | Add-AzLoadBalancerFrontendIpConfig -Name $LBFENAME -PublicIpAddress $publicIp | Set-AzLoadBalancer

$lb | Add-AzLoadBalancerBackendAddressPoolConfig -Name $LBBEPOOLNAME | Set-AzLoadBalancer

# Create an Azure Load Balancer health probe for HTTP
$lb | Add-AzLoadBalancerProbeConfig -Name 'http' -RequestPath '/' -Protocol http -Port 80 -IntervalInSeconds 15 -ProbeCount 2 | Set-AzLoadBalancer

# Create an Azure Load Balancer health probe for HTTPs (if SKU is Standard)
if($LBSKU -eq "Standard") {
 $lb | Add-AzLoadBalancerProbeConfig -Name 'https' -RequestPath '/' -Protocol https -Port 443 -IntervalInSeconds 15 -ProbeCount 2 | Set-AzLoadBalancer
}

# Create an inbound NAT pool with backend port 22
$feIpConfig = Get-AzLoadBalancerFrontendIpConfig -Loadbalancer $lb -Name $LBFENAME
$lb | Add-AzLoadBalancerInboundNatPoolConfig `
 -Name $LBNATPOOLNAME `
 -Protocol TCP `
 -FrontendIPConfigurationId $feIpConfig.Id `
 -FrontendPortRangeStart $LBFEPORTRANGESTART `
 -FrontendPortRangeEnd $LBFEPORTRANGEEND `
 -BackendPort 22 | Set-AzLoadBalancer

# Create a load balancing inbound rule for the port 80
$beAddressPool = Get-AzLoadBalancerBackendAddressPoolConfig -Loadbalancer $lb -Name $LBBEPOOLNAME
$probe = Get-AzLoadBalancerProbeConfig -Name "http" -LoadBalancer $lb
$lb | Add-AzLoadBalancerRuleConfig `
 -Name $LBRULEHTTPNAME `
 -FrontendIPConfigurationId $feIpConfig.Id `
 -BackendAddressPoolId $beAddressPool.Id `
 -Protocol "Tcp" `
 -FrontendPort 80 `
 -BackendPort 80 `
 -ProbeId $probe.Id | Set-AzLoadBalancer

# Create a load balancing inbound rule for the port 443 (if SKU is Standard)
if($LBSKU -eq "Standard") {
 $probe = Get-AzLoadBalancerProbeConfig -Name "https" -LoadBalancer $lb
 $lb | Add-AzLoadBalancerRuleConfig `
 -Name $LBRULEHTTPSNAME `
 -FrontendIPConfigurationId $feIpConfig.Id `
 -BackendAddressPoolId $beAddressPool.Id `
 -Protocol "Tcp" `
 -FrontendPort 443 `
 -BackendPort 443 `
 -ProbeId $probe.Id | Set-AzLoadBalancer
}