# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$VMSSNAME=$PREFIX+'VMSS'

# Set up here the names of the Azure Storage account and the container
$STORAGENAMEUNIQUE='XXXXXXXXXXXXXXX'
$STORAGECONTAINERNAME='XXXXXXXXXXXXXXX'

$BLOBSOURCEURI='./desktop/ps/app/package.tar.gz'
$BLOBFILEDESTINATIONNAME='package.tar.gz'
$SCRIPTUPDATESOURCEURI='./desktop/ps/scripts/update-app.sh'
$SCRIPTUPDATEFILEDESTINATIONAME='update-app.sh'
$DESTINATIONFOLDER='/var/www/html'
$SERVICETORESTART='apache2.service'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Set the storage account
Set-AzCurrentStorageAccount `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -AccountName $STORAGENAMEUNIQUE

# Upload both the application files and update application script to the blob storage
Set-AzStorageBlobContent `
  -File $BLOBSOURCEURI `
  -Container $STORAGECONTAINERNAME `
  -Blob $BLOBFILEDESTINATIONNAME

Set-AzStorageBlobContent `
  -File $SCRIPTUPDATESOURCEURI `
  -Container $STORAGECONTAINERNAME `
  -Blob $SCRIPTUPDATEFILEDESTINATIONAME

# Get the URLs from the uploaded files
$BLOBURL=(Get-AzStorageBlob -blob $BLOBFILEDESTINATIONNAME -Container $STORAGECONTAINERNAME).ICloudBlob.uri.AbsoluteUri
$SCRIPTURL=(Get-AzStorageBlob -blob $SCRIPTUPDATEFILEDESTINATIONAME -Container $STORAGECONTAINERNAME).ICloudBlob.uri.AbsoluteUri

# Build the Protected Settings JSON string
$STORAGEKEY = Get-AzStorageAccountKey -ResourceGroupName $RESOURCEGROUPNAME -Name $STORAGENAMEUNIQUE
$SETTINGS = @{"fileUris" = "[$BLOBURL,$SCRIPTURL]"; "commandToExecute" = "bash $SCRIPTUPDATEFILEDESTINATIONAME $BLOBFILEDESTINATIONNAME $DESTINATIONFOLDER $SERVICETORESTART"};
$PROTECTEDSETTINGS = @{"storageAccountName" = $STORAGENAME; "storageAccountKey" = $STORAGEKEY};

# Update the configuration file from the scale set
$vmss = Get-AzVmss -ResourceGroupName $RESOURCEGROUPNAME -VMScaleSetName $VMSSNAME
Add-AzVmssExtension `
 -VirtualMachineScaleSet $vmss `
 -Name CustomScript `
 -Publisher Microsoft.Azure.Extensions `
 -ForceUpdateTag 'true' `
 -TypeHandlerVersion 2.0 `
 -Setting $SETTINGS `
 -ProtectedSetting $PROTECTEDSETTINGS

# Update all the instances from the scale set
Get-AzVmssvm -ResourceGroupName $RESOURCEGROUPNAME -VMScaleSetName $VMSSNAME | ForEach-Object {
    Update-AzVmssInstance -ResourceGroupName $RESOURCEGROUPNAME -VMScaleSetName $VMSSNAME -InstanceId $_.InstanceId
}