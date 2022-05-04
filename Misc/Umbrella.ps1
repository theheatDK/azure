$ContainerName              = 'umbrella-disks'
$ErrorActionPreference      = 'Stop'
$LocationName               = 'westeurope'
$StorageaccountName         = 'stmyumbrellap001'
$ResourceGroupName          = 'rg-sharedservices-umbrella-p'
$SkuName                    = 'Standard_LRS'
$SubscriptionName           = 'sub-sharedservices-001'
$WarningPreference          = 'SilentlyContinue'

$Null = Set-AzContext -Subscription $SubscriptionName

$Null = New-AzResourceGroup -name $ResourceGroupName -location $LocationName

$Null = New-AzStorageAccount  `
  -AllowBlobPublicAccess $false `
  -Kind 'StorageV2' `
  -Location $LocationName `
  -MinimumTlsVersion 'TLS1_2' `
  -Name $StorageaccountName `
  -ResourceGroupName $ResourceGroupName `
  -SkuName $SkuName

$Acc  = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageaccountName
$Key  = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageaccountName | Where-Object {$_.KeyName -eq 'key1'}
$Ctx  = New-AzStorageContext -StorageAccountName $StorageaccountName -StorageAccountKey $Key.Value
$Null = New-AzStorageContainer -Name $ContainerName -Context $Ctx

# OS-disk
$Null = Set-AzStorageBlobContent -File ./forwarder-fixed.vhd -Container $ContainerName -Blob 'forwarder-fixed.vhd' -BlobType 'Page' -Context $Ctx
# Data-disk
$Null = Set-AzStorageBlobContent -File ./dynamic.vhd -Container $ContainerName -Blob 'dynamic.vhd' -BlobType 'Page' -Context $Ctx

$ImageConfig      = New-AzImageConfig -Location $LocationName -HypervGeneration 'V1'
$OsDiskVhdUri     = 'https://stmyumbrellap001.blob.core.windows.net/umbrella-disks/forwarder-fixed.vhd'
$DataDiskVhdUri   = 'https://stmyumbrellap001.blob.core.windows.net/umbrella-disks/dynamic.vhd'
$Null             = Set-AzImageOsDisk -Image $ImageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $OsDiskVhdUri -Caching 'ReadWrite' -StorageAccountType 'Standard_LRS'
$Null             = Add-AzImageDataDisk -Image $ImageConfig -Lun '0' -BlobUri $DataDiskVhdUri -Caching 'ReadWrite' -StorageAccountType 'Standard_LRS'
$Null             = New-AzImage -Image $ImageConfig -ImageName 'umbrella' -ResourceGroupName $ResourceGroupName