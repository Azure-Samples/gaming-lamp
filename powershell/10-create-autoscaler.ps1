# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$VMSSVMTOCREATE=2
$VMSSNAME=$PREFIX+'VMSS'
$VMSSAUTOSCALERNAME=$PREFIX+'Autoscaler'
$VMSSAUTOSCALERCRITERIA='Percentage CPU'
$VMSSAUTOSCALERMAXCOUNT=10
$VMSSAUTOSCALERMINCOUNT=$VMSSVMTOCREATE
$VMSSAUTOSCALERUPTRIGGER=50
$VMSSAUTOSCALERDOWNTRIGGER=30
$VMSSAUTOSCALEROUTINCREASE=1
$VMSSAUTOSCALERINDECREASE=1

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Enable virtual machine autoscaler for scaling out
$scaleOutRule = New-AzAutoscaleRule `
 -MetricName $VMSSAUTOSCALERCRITERIA `
 -MetricResourceId /subscriptions/$YOURSUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Compute/virtualMachineScaleSets/$VMSSNAME `
 -Operator GreaterThan `
 -MetricStatistic Average `
 -Threshold $VMSSAUTOSCALERUPTRIGGER `
 -TimeGrain 00:01:00 `
 -TimeWindow 00:05:00 `
 -ScaleActionCooldown 00:05:00 `
 -ScaleActionDirection Increase `
 -ScaleActionValue $VMSSAUTOSCALEROUTINCREASE

# Enable virtual machine autoscaler for scaling in
$scaleInRule = New-AzAutoscaleRule `
 -MetricName $VMSSAUTOSCALERCRITERIA `
 -MetricResourceId /subscriptions/$YOURSUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Compute/virtualMachineScaleSets/$VMSSNAME `
 -Operator LessThan `
 -MetricStatistic Average `
 -Threshold $VMSSAUTOSCALERDOWNTRIGGER `
 -TimeGrain 00:01:00 `
 -TimeWindow 00:05:00 `
 -ScaleActionCooldown 00:05:00 `
 -ScaleActionDirection Decrease `
 -ScaleActionValue $VMSSAUTOSCALERINDECREASE

# Create an autoscaler profile using the previously defined autoscaling rules
$autoscalerProfile = New-AzAutoscaleProfile `
 -DefaultCapacity $VMSSVMTOCREATE `
 -MaximumCapacity $VMSSAUTOSCALERMAXCOUNT `
 -MinimumCapacity $VMSSAUTOSCALERMINCOUNT `
 -Rule $scaleOutRule,$scaleInRule `
 -Name $VMSSAUTOSCALERNAME

# Creating the autoscaler per se
Add-AzAutoscaleSetting `
 -ResourceGroup $RESOURCEGROUPNAME `
 -Location $REGIONNAME `
 -Name $VMSSAUTOSCALERNAME `
 -TargetResourceId /subscriptions/$YOURSUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME/providers/Microsoft.Compute/virtualMachineScaleSets/$VMSSNAME `
 -AutoscaleProfile $autoscalerProfile 
