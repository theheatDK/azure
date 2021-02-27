###############################################################################
# Creates an Azure AD Conditional Access Excel report
###############################################################################
$ErrorActionPreference  = 'Stop'
$WarningPreference      = 'SilentlyContinue'

$ExcelFilePath          = 'c:\temp\'

$DateTime               = Get-Date -Format 'MM/dd/yyyy-HHmm'
$ExcelFileName          = "AzureADConditionalAccessReport-$($DateTime).xlsx"
$ExcelFileName          = "$($ExcelFilePath)$($ExcelFileName)"
Remove-Item $ExcelFileName -ErrorAction Ignore

$ApplicationsList       = @()
$GrantsList             = @()
$LocationsList          = @()
$PlatformsList          = @()
$PoliciesList           = @()
$SessionControlsList    = @()
$UsersList              = @()

# Verify connections
$AzureADTenantName      = (Get-AzureADTenantDetail).DisplayName
$AzTenantName           = (Get-AzTenant).Name

if ($AzureADTenantName -ne $AzTenantName) {
    Write-Error "Azure AD tenant name mismatch - $($AzureADTenantName) does match $($AzTenantName)"
    return
}

$Tenant     = Get-AzTenant
$Domains    = ''
foreach ($Domain in $Tenant.Domains) {
    $Domains += $Domain + "`n"
}
$Tenant = [PSCustomObject]@{
    Name        = $Tenant.Name
    Id          = $Tenant.Id
    Domains     = $Domains
    CountryCode = $Tenant.ExtendedProperties.CountryCode
}

$Policies = Get-AzureADMSConditionalAccessPolicy | Sort-Object -Property DisplayName

# Policies general
foreach ($Policy in $Policies) {
    $Dummy = [PSCustomObject]@{
        DisplayName = $Policy.DisplayName
        Id          = $Policy.Id
        State       = $Policy.State
    }
    $PoliciesList += $Dummy
}

# Applications
foreach ($Policy in $Policies) {
    $IncludeApplications = $Null
    foreach ($IncludeApplication in $Policy.Conditions.Applications.IncludeApplications) {
        if ($IncludeApplication.split('-').count -eq 5) {
            $App = Get-AzADServicePrincipal -ApplicationId $IncludeApplication
            if ($App) {
                $IncludeApplication = "$($IncludeApplication) - $($App.DisplayName)"
            }
        }
        $IncludeApplications += $IncludeApplication + "`n"
    }
    if ($IncludeApplications) {
        $IncludeApplications = $IncludeApplications.Substring(0,$IncludeApplications.Length-1)
    }

    $ExcludeApplications = $Null
    foreach ($ExcludeApplication in $Policy.Conditions.Applications.ExcludeApplications) {
        if ($ExcludeApplication.split('-').count -eq 5) {
            $App = Get-AzADServicePrincipal -ApplicationId $ExcludeApplication
            if ($App) {
                $ExcludeApplication = "$($ExcludeApplication) - $($App.DisplayName)"
            }
        }
        $ExcludeApplications += $ExcludeApplication + "`n"
    }
    if ($ExcludeApplications) {
        $ExcludeApplications = $ExcludeApplications.Substring(0,$ExcludeApplications.Length-1)
    }

    $IncludeUserActions = $Null
    foreach ($IncludeUserAction in $Policy.Conditions.Applications.IncludeUserActions) {
        $IncludeUserActions += $IncludeUserAction + "`n"
    }

    $Dummy = [PSCustomObject]@{
        Policy              = $Policy.DisplayName
        IncludeApplications = $IncludeApplications
        ExcludeApplications = $ExcludeApplications
        IncludeUserActions  = $IncludeUserActions
    }
    $ApplicationsList += $Dummy
}

# Users
foreach ($Policy in $Policies) {
    $IncludeUsers = $Null
    foreach ($IncludeUser in $Policy.Conditions.Users.IncludeUsers) {
        if ($IncludeUser.split('-').count -eq 5) {
            $User = Get-AzADUser -ObjectId $IncludeUser
            if ($User) {
                $IncludeUser = "$($IncludeUser) - $($User.Mail)"
            }
        }
        $IncludeUsers += $IncludeUser + "`n"
    }
    if ($IncludeUsers) {
        $IncludeUsers = $IncludeUsers.Substring(0,$IncludeUsers.Length-1)
    }

    $ExcludeUsers = $Null
    foreach ($ExcludeUser in $Policy.Conditions.Users.ExcludeUsers) {
        if ($ExcludeUser.split('-').count -eq 5) {
            $User = Get-AzADUser -ObjectId $ExcludeUser
            if ($User) {
                $ExcludeUser = "$($ExcludeUser) - $($User.Mail)"
            }
        }
        $ExcludeUsers += $ExcludeUser + "`n"
    }
    if ($ExcludeUsers) {
        $ExcludeUsers = $ExcludeUsers.Substring(0,$ExcludeUsers.Length-1)
    }

    $IncludeGroups = $Null
    foreach ($IncludeGroup in $Policy.Conditions.Users.IncludeGroups) {
        if ($IncludeGroup.split('-').count -eq 5) {
            $Group = Get-AzADGroup -ObjectId $IncludeGroup
            if ($Group) {
                $IncludeGroup = "$($IncludeGroup) - $($Group.DisplayName)"
            }
        }
        $IncludeGroups += $IncludeGroup + "`n"
    }
    if ($IncludeGroups) {
        $IncludeGroups = $IncludeGroups.Substring(0,$IncludeGroups.Length-1)
    }

    $ExcludeGroups = $Null
    foreach ($ExcludeGroup in $Policy.Conditions.Users.ExcludeGroups) {
        if ($ExcludeGroup.split('-').count -eq 5) {
            $Group = Get-AzADGroup -ObjectId $ExcludeGroup
            if ($Group) {
                $ExcludeGroup = "$($ExcludeGroup) - $($Group.DisplayName)"
            }
        }
        $ExcludeGroups += $ExcludeGroup + "`n"
    }
    if ($ExcludeGroups) {
        $ExcludeGroups = $ExcludeGroups.Substring(0,$ExcludeGroups.Length-1)
    }

    $IncludeRoles = $Null
    foreach ($IncludeRole in $Policy.Conditions.Users.IncludeRoles) {
        if ($IncludeRole.split('-').count -eq 5) {
            try {
                $Role        = Get-AzureADDirectoryRole -Filter "roleTemplateId eq '$($IncludeRole)'"
                $IncludeRole = "$($IncludeRole) - $($Role.DisplayName)"
            } catch {}
        }
        $IncludeRoles += $IncludeRole + "`n"
    }
    if ($IncludeRoles) {
        $IncludeRoles = $IncludeRoles.Substring(0,$IncludeRoles.Length-1)
    }

    $ExcludeRoles = $Null
    foreach ($ExcludeRole in $Policy.Conditions.Users.ExcludeRoles) {
        if ($ExcludeRole.split('-').count -eq 5) {
            try {
                $Role        = Get-AzureADDirectoryRole -Filter "roleTemplateId eq '$($ExcludeRole)'"
                $ExcludeRole = "$($ExcludeRole) - $($Role.DisplayName)"
            } catch {}
        }
        $ExcludeRoles += $ExcludeRole + "`n"
    }
    if ($ExcludeRoles) {
        $ExcludeRoles = $ExcludeRoles.Substring(0,$ExcludeRoles.Length-1)
    }

    $Dummy = [PSCustomObject]@{
        Policy              = $Policy.DisplayName
        IncludeUsers        = $IncludeUsers
        ExcludeUsers        = $ExcludeUsers
        IncludeGroups       = $IncludeGroups
        ExcludeGroups       = $ExcludeGroups
        IncludeRoles        = $IncludeRoles
        ExcludeRoles        = $ExcludeRoles
    }
    $UsersList += $Dummy
}

# Platforms
foreach ($Policy in $Policies) {
    $IncludePlatforms = $Null
    foreach ($IncludePlatform in $Policy.Conditions.Platforms.IncludePlatforms) {
        $IncludePlatforms += $IncludePlatform.ToString() + "`n"
    }
    if ($IncludePlatforms) {
        $IncludePlatforms = $IncludePlatforms.Substring(0,$IncludePlatforms.Length-1)
    }

    $ExcludePlatforms = $Null
    foreach ($ExcludePlatform in $Policy.Conditions.Platforms.ExcludePlatforms) {
        $ExcludePlatforms += $ExcludePlatform.ToString() + "`n"
    }
    if ($ExcludePlatforms) {
        $ExcludePlatforms = $ExcludePlatforms.Substring(0,$ExcludePlatforms.Length-1)
    }

    $Dummy = [PSCustomObject]@{
        Policy              = $Policy.DisplayName
        IncludePlatforms    = $IncludePlatforms
        ExcludePlatforms    = $ExcludePlatforms
    }
    $PlatformsList += $Dummy
}

# Locations
foreach ($Policy in $Policies) {
    $IncludeLocations = $Null
    foreach ($IncludeLocation in $Policy.Conditions.Locations.IncludeLocations) {
        if ($IncludeLocation -eq '00000000-0000-0000-0000-000000000000') {
            $IncludeLocation += ' - MFA Trusted IPs'
        } elseif ($IncludeLocation.split('-').count -eq 5) {
            try {
                $Location        = Get-AzureADMSNamedLocationPolicy -PolicyId $IncludeLocation
                $IncludeLocation = "$($IncludeLocation) - $($Location.DisplayName)"
            } catch {}
        }
        $IncludeLocations += $IncludeLocation + "`n"
    }
    if ($IncludeLocations) {
        $IncludeLocations = $IncludeLocations.Substring(0,$IncludeLocations.Length-1)
    }

    $ExcludeLocations = $Null
    foreach ($ExcludeLocation in $Policy.Conditions.Locations.ExcludeLocations) {
        if ($ExcludeLocation -eq '00000000-0000-0000-0000-000000000000') {
            $ExcludeLocation += ' - MFA Trusted IPs'
        } elseif ($ExcludeLocation.split('-').count -eq 5) {
            try {
                $Location        = Get-AzureADMSNamedLocationPolicy -PolicyId $ExcludeLocation
                $ExcludeLocation = "$($ExcludeLocation) - $($Location.DisplayName)"
            } catch {}
        }
        $ExcludeLocations += $ExcludeLocation + "`n"
    }
    if ($ExcludeLocations) {
        $ExcludeLocations = $ExcludeLocations.Substring(0,$ExcludeLocations.Length-1)
    }

    $Dummy = [PSCustomObject]@{
        Policy              = $Policy.DisplayName
        IncludeLocations    = $IncludeLocations
        ExcludeLocations    = $ExcludeLocations
    }
    $LocationsList += $Dummy
}

# GrantControls
foreach ($Policy in $Policies) {
    $BuiltInControls = $Null
    foreach ($BuiltInControl in $Policy.GrantControls.BuiltInControls) {
        $BuiltInControls += $BuiltInControl.ToString() + "`n"
    }
    if ($BuiltInControls) {
        $BuiltInControls = $BuiltInControls.Substring(0,$BuiltInControls.Length-1)
    }

    $CustomAuthenticationFactors = $Null
    foreach ($CustomAuthenticationFactor in $Policy.GrantControls.CustomAuthenticationFactors) {
        $CustomAuthenticationFactors += $CustomAuthenticationFactors + "`n"
    }
    if ($CustomAuthenticationFactors) {
        $CustomAuthenticationFactors = $CustomAuthenticationFactors.Substring(0,$CustomAuthenticationFactors.Length-1)
    }

    $TermsOfUses = $Null
    foreach ($TermsOfUse in $Policy.GrantControls.TermsOfUse) {
        $TermsOfUses += $TermsOfUse + "`n"
    }
    if ($TermsOfUses) {
        $TermsOfUses = $TermsOfUses.Substring(0,$TermsOfUses.Length-1)
    }

    $Dummy = [PSCustomObject]@{
        Policy                      = $Policy.DisplayName
        BuiltInControls             = $BuiltInControls
        CustomAuthenticationFactors = $CustomAuthenticationFactors
        TermsOfUses                 = $TermsOfUses
    }
    $GrantsList += $Dummy
}

# SessionControls
foreach ($Policy in $Policies) {
    $ApplicationEnforcedRestrictions = $Null
    foreach ($ApplicationEnforcedRestriction in $Policy.SessionControls.ApplicationEnforcedRestrictions) {
        $ApplicationEnforcedRestrictions += $ApplicationEnforcedRestriction.ToString() + "`n"
    }
    if ($ApplicationEnforcedRestrictions) {
        $ApplicationEnforcedRestrictions = $ApplicationEnforcedRestrictions.Substring(0,$ApplicationEnforcedRestrictions.Length-1)
    }

    $CloudAppSecuritys = $Null
    foreach ($CloudAppSecurity in $Policy.SessionControls.CloudAppSecurity) {
        $CloudAppSecuritys += $CloudAppSecurity.ToString() + "`n"
    }
    if ($CloudAppSecuritys) {
        $CloudAppSecuritys = $CloudAppSecuritys.Substring(0,$CloudAppSecuritys.Length-1)
    }

    $SignInFrequencys = $Null
    foreach ($SignInFrequency in $Policy.SessionControls.SignInFrequency) {
        $SignInFrequencys += "Type: $($SignInFrequency.Type.ToString()), Value: $($SignInFrequency.Value), IsEnabled: $($SignInFrequency.IsEnabled.ToString())"
    }

    $PersistentBrowsers = $Null
    foreach ($PersistentBrowser in $Policy.SessionControls.PersistentBrowser) {
        $PersistentBrowsers += "Mode: $($PersistentBrowser.Mode.ToString()), IsEnabled: $($PersistentBrowser.IsEnabled.ToString())"
    }

    $Dummy = [PSCustomObject]@{
        Policy                          = $Policy.DisplayName
        ApplicationEnforcedRestrictions = $ApplicationEnforcedRestrictions
        CloudAppSecuritys               = $CloudAppSecuritys
        SignInFrequencys                = $SignInFrequencys
        PersistentBrowsers              = $PersistentBrowsers
    }
    $SessionControlsList += $Dummy
}

# Output to Excel
$ExcelPackage   = $Tenant | Export-Excel $ExcelFileName -WorksheetName 'Tenant' -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Policies'
$ExcelPackage   = $PoliciesList  | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Applications'
$ExcelPackage   = $ApplicationsList | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Users'
$ExcelPackage   = $UsersList | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Platforms'
$ExcelPackage   = $PlatformsList | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Locations'
$ExcelPackage   = $LocationsList | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Grants'
$ExcelPackage   = $GrantsList | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru

$WorkSheet      = Add-WorkSheet -ExcelPackage $ExcelPackage -WorksheetName 'Sessions'
$ExcelPackage   = $SessionControlsList | Export-Excel -ExcelPackage $ExcelPackage -WorksheetName $WorkSheet.Name -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru

$BackgroundColor = [System.Drawing.Color]::FromArgb(77,87,93)
$TabColor        = [System.Drawing.Color]::FromArgb(237,238,238)
foreach ($WorkSheet in $ExcelPackage.Workbook.WorkSheets) {
    Set-Format -WorkSheet $WorkSheet -Range '1:1' -BackgroundColor $BackgroundColor -FontColor 'White'
    $WorkSheet.TabColor = $TabColor
    foreach ($Column in 1..$WorkSheet.Dimension.Columns) {
        $WorkSheet.Column($Column).Style.VerticalAlignment  = 'Top'
        $WorkSheet.Column($Column).Style.WrapText           = $True
    }
}
Close-ExcelPackage $ExcelPackage
