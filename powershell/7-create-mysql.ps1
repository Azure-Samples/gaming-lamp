# Install Azure PowerShell module (needs admin privilege)
Install-Module -Name Az -AllowClobber

# Variables to edit
$YOURSUBSCRIPTIONID='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
$RESOURCEGROUPNAME='myResourceGroup'
$REGIONNAME='japanwest'
$PREFIX='myGameBackend'

$RANDOMNUMBER=Get-Random
$MYSQLNAME=$PREFIX+'MySQL'
$MYSQLNAMELOWER=$MYSQLNAME.tolower()
$MYSQLNAMEUNIQUE=$MYSQLNAMELOWER+$RANDOMNUMBER
$MYSQLUSERNAME='azuremysqluser'
$MYSQLPASSWORD='CHang3thisP4Ssw0rD'
$MYSQLDBNAME='gamedb'
$MYSQLBACKUPRETAINEDDAYS=7
$MYSQLGEOREDUNDANTBACKUP='Disabled'
$MYSQLSKU='GP_Gen5_2'
$MYSQLSTORAGEMBSIZE=51200
$MYSQLVERSION='5.7'
$MYSQLREADREPLICANAME=$MYSQLNAMEUNIQUE+'Replica'
$MYSQLREADREPLICAREGION='westus'
$MYSQLSUBNETNAME=$MYSQLNAME+'Subnet'
$MYSQLSUBNETADDRESSPREFIX='10.0.2.0/24'
$MYSQLRULENAME=$MYSQLNAME+'Rule'

# Connect to Azure
Connect-AzAccount

# Set the Azure subscription
Set-AzContext `
 -SubscriptionId $YOURSUBSCRIPTIONID

# Create the server, database and other routinely tasks
$storageProfileVariable = @{
    "storageMB"=$MYSQLSTORAGEMBSIZE;
    "backupRetentionDays"=$MYSQLBACKUPRETAINEDDAYS;
    "geoRedundantBackup"=$MYSQLGEOREDUNDANTBACKUP
}

New-AzResource `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -ResourceType "Microsoft.DBforMySQL/servers" `
 -ResourceName $MYSQLNAMEUNIQUE `
 -ApiVersion 2017-12-01 `
 -Location $REGIONNAME `
 -SkuObject @{name=$MYSQLSKU} `
 -PropertyObject @{version = $MYSQLVERSION; administratorLogin = $MYSQLUSERNAME; administratorLoginPassword = $MYSQLPASSWORD; storageProfile=$storageProfileVariable} `

New-AzResource `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -ResourceType "Microsoft.DBforMySQL/servers/firewallRules" `
 -ResourceName $MYSQLNAMEUNIQUE/rule1 `
 -ApiVersion 2017-12-01 `
 -PropertyObject @{startIpAddress="0.0.0.0"; endIpAddress="255.255.255.255"}

New-AzResource `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -ResourceType "Microsoft.DBforMySQL/servers/databases" `
 -ResourceName $MYSQLNAMEUNIQUE/$MYSQLDBNAME `
 -ApiVersion 2017-12-01 `
 -PropertyObject @{collation='utf8_general_ci'; charset='utf8'}

Set-AzResource `
 -ResourceGroupName $RESOURCEGROUPNAME `
 -ResourceType "Microsoft.DBforMySQL/servers" `
 -ResourceName $MYSQLNAMEUNIQUE `
 -ApiVersion 2017-12-01 `
 -PropertyObject @{allowAzureServices='true'} `
 -Resources @{allowAzureServices='true'} `
 -UsePatchSemantics
