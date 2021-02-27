###############################################################################
# Setup. The script connectes to Azure via both Az and AzureAD
###############################################################################

# All of the below should be executed as an Administrator user

# Minimum 7.1.1
Install-Module -Name ImportExcel
Get-Module -Name ImportExcel

# AzureAD currently only works for Windows Powershell!
# Minimum 2.0.2.130
Install-Module -Name AzureAD
Get-Module -Name AzureAD

Install-Module -Name Az -AllowClobber -Scope CurrentUser
Get-InstalledModule -Name Az -AllVersions | Select-Object Name,Version

###############################################################################
# Connect
###############################################################################
Connect-AzureAD

Connect-AzAccount

###############################################################################
# Test access
###############################################################################

# AzureAD
Get-AzureADTenantDetail | Select-Object DisplayName

# Az
Get-AzTenant | Select-Object Name
