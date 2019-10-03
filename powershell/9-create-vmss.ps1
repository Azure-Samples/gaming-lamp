# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$LOGINUSERNAME='azureuser'
$LOGINPASSWORD= ConvertTo-SecureString 'CHang3thisP4Ssw0rD' -AsPlainText -Force
$LBNAME=$PREFIX+'LB'
$VNETNAME=$PREFIX+'VNET'
$SUBNETNAME=$PREFIX+'Subnet'

$VMSSNAME=$PREFIX+'VMSS'
$GOLDENIMAGENAME='myGoldenImage'
$VMSSSKUSIZE='Standard_B1s'
$VMSSVMTOCREATE=2
$VMSSSTORAGESKU='Premium_LRS'
$VMSSACELERATEDNETWORKING='false'
$VMSSUPGRADEPOLICY='Manual'
$HEALTHPROBEID='/subscriptions/'+$YOURSUBSCRIPTIONID+'/resourceGroups/'+$RESOURCEGROUPNAME+'/providers/Microsoft.Network/loadBalancers/'+$LBNAME+'/probes/http'
$VMSSOVERPROVISIONING='false'

if ($VMSSACELERATEDNETWORKING -eq 'true') {
    $VMSSACELERATEDNETWORKING='-EnableAcceleratedNetworking'
} else {
    $VMSSACELERATEDNETWORKING=''
}

if ($VMSSOVERPROVISIONING -eq 'true') {
    $overprovisioning=$True
} else {
    $overprovisioning=$False
}

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create a scale set
$vnet = Get-AzVirtualNetwork -ResourceGroupName $RESOURCEGROUPNAME -Name $VNETNAME
$subnetId = $vnet.Id + '/subnets/' + $SUBNETNAME
$lb = Get-AzLoadBalancer -ResourceGroupName $RESOURCEGROUPNAME -Name $LBNAME

$ipConfig = New-AzVmssIpConfig `
  -Name "myIPConfig" `
  -LoadBalancerBackendAddressPoolsId $lb.BackendAddressPools[0].Id `
  -LoadBalancerInboundNatPoolsId $lb.InboundNatPools[0].Id `
  -SubnetId $subnetId

$vmssConfig = New-AzVmssConfig `
  -Location $REGIONNAME `
  -SkuCapacity $VMSSVMTOCREATE `
  -SkuName $VMSSSKUSIZE `
  -UpgradePolicyMode $VMSSUPGRADEPOLICY `
  -HealthProbeId $HEALTHPROBEID `
  -Overprovision $overprovisioning

$customImage = Get-AzImage -ResourceGroupName $RESOURCEGROUPNAME -ImageName $GOLDENIMAGENAME
Set-AzVmssStorageProfile `
  -VirtualMachineScaleSet $vmssConfig `
  -OsDiskCreateOption 'FromImage' `
  -ManagedDisk $VMSSSTORAGESKU `
  -OsDiskOsType Linux `
  -ImageReferenceId $customImage.Id

Set-AzVmssOsProfile `
 -VirtualMachineScaleSet $vmssConfig `
 -ComputerNamePrefix $PREFIX `
 -AdminUsername $LOGINUSERNAME `
 -AdminPassword $LOGINPASSWORD

Add-AzVmssNetworkInterfaceConfiguration `
  -VirtualMachineScaleSet $vmssConfig `
  -Name "network-config" `
  -Primary $True `
  -IPConfiguration $ipConfig $VMSSACELERATEDNETWORKING

New-AzVmss `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -VMScaleSetName $VMSSNAME `
 -VirtualMachineScaleSet $vmssConfig

# Confirm scale set upgrade policy
Get-AzVmss `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -VMScaleSetName $VMSSNAME | select -expandproperty UpgradePolicy

# Switch to Rolling upgrade mode
$vmss = Get-AzVmss `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -VMScaleSetName $VMSSNAME

Set-AzVmssRollingUpgradePolicy `
 -VirtualMachineScaleSet $vmss `
 -MaxBatchInstancePercent 35 `
 -MaxUnhealthyInstancePercent 40 `
 -MaxUnhealthyUpgradedInstancePercent 30 `
 -PauseTimeBetweenBatches 'PT30S'

Update-AzVmss `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -VMScaleSetName $VMSSNAME `
 -VirtualMachineScaleSet $vmss `
 -UpgradePolicyMode Rolling
