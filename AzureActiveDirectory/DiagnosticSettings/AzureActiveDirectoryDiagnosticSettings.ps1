###############################################################################
# Create a Log analytics workspace and configure Azure AD to send diagnostics logs to it.
#
# This script must be executed by a user with the Global Administrator role.
# The user must also have the Contributor role for the subscription.
# The easiest way to accomplish this is by temporarily elevating access to manage all Azure
# subscriptions for the user:
# https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin#elevate-access-for-a-global-administrator
###############################################################################
$ErrorActionPreference          = 'Stop'
$Location                       = 'westeurope'
$LogAnalyticsWorkspaceName      = 'log-sbs-manage-govern-p-001'
$ResourceGroupName              = 'rg-sbs-manage-govern-p'
$RetentionInDays                = 90
$Sku                            = 'pergb2018'
$SubscriptionName               = 'management-p-001'
$WarningPreference              = 'SilentlyContinue'

$Null       = Set-AzContext -Subscription $SubscriptionName
$Null       = Register-AzResourceProvider -ProviderNamespace 'microsoft.insights'

while ($True) {
    $Providers = Get-AzResourceProvider -ProviderNamespace 'microsoft.insights' -Location $Location | Where-Object { $_.RegistrationState -eq 'Registered' }
    if ($Providers) {
        break
    }
    Write-Output 'Sleeping for 60 seconds'
    Start-Sleep -Seconds 60
}

$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction 'SilentlyContinue'
if (!$ResourceGroup) {
    $Null = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

$LogAnalyticsWorkspace = Get-AzOperationalInsightsWorkspace -Name $LogAnalyticsWorkspaceName -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue'

if (!$LogAnalyticsWorkspace) {
    $LogAnalyticsWorkspace = New-AzOperationalInsightsWorkspace -Location $Location -Name $LogAnalyticsWorkspaceName -Sku $Sku -ResourceGroupName $ResourceGroupName
}

$Null = Set-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $LogAnalyticsWorkspaceName -RetentionInDays $RetentionInDays

$Null = New-AzTenantDeployment -Location $Location -TemplateFile ./DiagnosticSettings.json -LogAnalyticsResourceId $LogAnalyticsWorkspace.ResourceId
