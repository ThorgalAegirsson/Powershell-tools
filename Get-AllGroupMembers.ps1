# put the correct distribution list name in the $group below. Use pre-Windows 2000 group name

$group = "Industry Engagement Forum-1298172433"
$members = (Get-ADGroup $group -Properties member).member
$users = @()

Write-Host "Group: $($group)" -ForegroundColor Yellow

foreach ($member in $members) {
    $user = Get-ADObject -Identity $member -Properties * | Select-Object -ExpandProperty mail
    Write-Host " $($user)"
    $users += $user
}

$users | Out-File -Append $home\Desktop\$($group)_userlist.txt
