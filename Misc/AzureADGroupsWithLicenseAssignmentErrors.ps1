$TenantId = 'XXXXX-YYY'

Connect-MgGraph -TenantId $TenantId -Scopes @('Group.Read.All')

$Groups = Get-MgGroup -All -Filter 'hasMembersWithLicenseErrors eq true' -Property 'DisplayName, Id, AssignedLicenses'

foreach($Group in $Groups) {
    $GroupMembersWithLicenseError = Get-MgGroupMemberWithLicenseError -All -GroupId $Group.Id
    foreach($GroupMemberWithLicenseError in $GroupMembersWithLicenseError) {
        "$($Group.DisplayName) - $($GroupMemberWithLicenseError.AdditionalProperties.userPrincipalName)"
    }
}