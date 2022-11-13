# The script gets all members of a distribution list, including members from outside of the organization saved in AD as email addresses, not only the AD users


# put the correct distribution list name in the -group parameter. Use pre-Windows 2000 group name
# USAGE
# Get-AllGroupMembers -group "Industry Engagement Forum-1298172433"


Param(
    [Parameter(Mandatory, HelpMessage="Provide the group using pre-Windows 2000 name")]
    [string]$group
)

$members = (Get-ADGroup $group -Properties member).member
$users = @()

Write-Host "Group: $($group)" -ForegroundColor Yellow

foreach ($member in $members) {
    $user = Get-ADObject -Identity $member -Properties * | Select-Object -ExpandProperty mail
    Write-Host " $($user)"
    $users += $user
}

$users | Out-File -Append $home\Desktop\$($group)_userlist.txt
