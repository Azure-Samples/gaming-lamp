# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='4079abbe-ef74-4c5d-81d8-f3d2d297a2db'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'
$LOGINUSERNAME='azureuser'
$LOGINPASSWORD = ConvertTo-SecureString 'CHang3thisP4Ssw0rD' -AsPlainText -Force
$VMNAME='myVirtualMachine'
$IMAGE='Canonical:UbuntuServer:16.04-LTS:latest'
$VMSIZE='Standard_B1s'
$VMDATADISKSIZEINGB=5

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create resource group
Write-Host Creating resource group named $RESOURCEGROUPNAME in region $REGIONNAME
New-AzResourceGroup `
 -Name $RESOURCEGROUPNAME `
 -Location $REGIONNAME

# Create the credentials object
$VMCREDENTIALS = New-Object System.Management.Automation.PSCredential ($LOGINUSERNAME, $LOGINPASSWORD);

# Create an Azure Virtual Machine
Write-Host Creating a virtual machine named $VMNAME with size $VMSIZE and opening ports 80, 443 and 22, note that it will take a few minutes
New-AzVM `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VMNAME `
 -Image $IMAGE `
 -Size $VMSIZE `
 -Credential $VMCREDENTIALS `
 -DataDiskSizeInGb $VMDATADISKSIZEINGB `
 -OpenPorts 80,443,22 `

# Get the public IP address from the Azure Virtual Machine just created
Get-AzVM `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -Name $VMNAME | Get-AzPublicIpAddress | Select-Object IPAddress
