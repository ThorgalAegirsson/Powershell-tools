# script to verify users' division and membership in 4 distributions lists
# Not very robust - the only input is the user list in form of csv
# the distribution lists are hard-coded
# the only error checking is a test whether a user exists before it moves on with the rest of script

Param(
    [Parameter(Mandatory, HelpMessage="Provide the path to the list of users")]
    [string]$userList
)

$users = Import-Csv $userList

$marketGroup = @()
$retailGroup = @()
$wholesaleGroup = @()
$corporateGroup = @()

#Convert group members to SID
$marketFrameworkMembers = (Get-ADGroup 'Market Framework' -Properties member).member
foreach ($member in $marketFrameworkMembers) {
    $user = Get-ADUser -Identity $member
    $userSID = $user.SID.ToString()
    $marketGroup += $userSID
}

$wholesaleMembers = (Get-ADGroup 'Market Operations' -Properties member).member
foreach ($member in $wholesaleMembers) {
    $user = Get-ADUser -Identity $member
    $userSID = $user.SID.ToString()
    $wholesaleGroup += $userSID
}

$retailMembers = (Get-ADGroup 'Retail' -Properties member).member
foreach ($member in $retailMembers) {
    $user = Get-ADUser -Identity $member
    $userSID = $user.SID.ToString()
    $retailGroup += $userSID
}

$corporateAffairsMembers = (Get-ADGroup 'Corporate Affairs' -Properties member).member
foreach ($member in $corporateAffairsMembers) {
    $user = Get-ADUser -Identity $member
    $userSID = $user.SID.ToString()
    $corporateGroup += $userSID
}
foreach ($user in $users) {
    $userName = $user.Name.toString()
    
    # get AD object
    try {
        $ADObject = Get-ADUser -Filter 'Name -like $userName'
        
        
    }
    catch {
        Write-Host "Error occurred while retrieving $userName" -ForegroundColor Red
    }
    # get SID from AD
    $SID = $ADObject.SID.ToString()

    # get division from AD
    $Division = 'UNDISCOVERED'
    if (Select-String -Pattern "Corporate Affairs" -InputObject $ADObject) { $Division = 'Corporate Affairs'}
    if (Select-String -Pattern "Market Framework" -InputObject $ADObject) { $Division = 'Market Framework'}
    if (Select-String -Pattern "Retail and Consumer Services" -InputObject $ADObject) { $Division = 'Retail and Consumer Services'}
    if (Select-String -Pattern "Wholesale" -InputObject $ADObject) { $Division = 'Wholesale'}
    if (Select-String -Pattern "Wholesale Consultants" -InputObject $ADObject) { $Division = 'Wholesale Consultants'}
    if (Select-String -Pattern "Commissioners Office" -InputObject $ADObject) { $Division = 'Commissioners Office'}
    if (Select-String -Pattern "ExternalServiceProviders" -InputObject $ADObject) { $Division = 'External Service Providers'}
    if (Select-String -Pattern "Commissioners Office" -InputObject $ADObject) { $Division = 'Commissioners Office'}
    if (Select-String -Pattern "AzureServiceAccounts" -InputObject $ADObject) { $Division = 'Azure Service Accounts'}

   
    # add AD object to $users hashtable
    $user | Add-member -NotePropertyName SID -NotePropertyValue $SID
    $user.Division = $Division
    
    $user | Add-member -NotePropertyName "MarketFramework" -NotePropertyValue ""
    $user | Add-member -NotePropertyName "Wholesale" -NotePropertyValue ""
    $user | Add-member -NotePropertyName "Retail" -NotePropertyValue ""
    $user | Add-member -NotePropertyName "CorporateAffairs" -NotePropertyValue ""

    # test if user is in one of the distribution groups
    if ($marketGroup -contains $SID) {
        $user.MarketFramework = "TRUE"
        $newMarketGroup = $marketGroup -ne $SID
        $marketGroup = $newMarketGroup
    }
    if ($wholesaleGroup -contains $SID) {
        $user.Wholesale = "TRUE"
        $newWholesaleGroup = $wholesaleGroup -ne $SID
        $wholesaleGroup = $newWholesaleGroup
    }
    if ($retailGroup -contains $SID) {
        $user.Retail = "TRUE"
        $newRetailGroup = $retailGroup -ne $SID
        $retailGroup = $newRetailGroup
    }
    if ($corporateGroup -contains $SID) {
        $user.CorporateAffairs = "TRUE"
        $newCorporateGroup = $corporateGroup -ne $SID
        $corporateGroup = $newCorporateGroup
    }

}
Write-Host "market group" -ForegroundColor Yellow
Write-Host $marketGroup
Write-Host "wholesale group" -ForegroundColor Yellow
Write-Host $wholesaleGroup
Write-Host "retail group" -ForegroundColor Yellow
Write-Host $retailGroup
Write-Host "Corporate group" -ForegroundColor Yellow
Write-Host $corporateGroup

$users | ConvertTo-Csv | Out-File -FilePath output.csv
