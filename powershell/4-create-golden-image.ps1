# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'
$VMNAME='myVirtualMachine'
$GOLDENIMAGENAME='myGoldenImage'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Get the Azure Virtual Machine object
$vm = Get-AzVM `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VMNAME

# Create an image object using the Azure Virtual Machine as a reference
$image = New-AzImageConfig `
 -Location $REGIONNAME `
 -SourceVirtualMachineId $vm.ID

# Create the image per se
New-AzImage `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Image $image `
 -ImageName $GOLDENIMAGENAME
