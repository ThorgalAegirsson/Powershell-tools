Param(
    [Parameter(mandatory, HelpMessage="Provide the name of csv file with the list of mailboxes to scan")]
    [string]$listOfEmails
)

$mailboxes = @()

$templist = Import-Csv $listOfEmails -Header email

forEach($email in $templist) {
    $mailboxes += $email[0].email
}

forEach ($mailbox in $mailboxes) {
    Write-Host "`n$mailbox"
    # test last send
    Write-Host "`nLast received: " -NoNewline
    Get-TransportService | Get-MessageTrackingLog -Recipients $mailbox -EventId RECEIVE -Source SMTP | Sort-Object Timestamp -Descending | select Timestamp -First 1
    # test last received
    Write-Host "`nLast sent: " -NoNewLine
    Get-TransportService | Get-MessageTrackingLog -Sender $mailbox -EventId send -Source SMTP | Sort-Object Timestamp -Descending | select Timestamp -First 1
    # add to table   
    
    # Get permissions
    Get-MailboxPermission $mailbox | select user,accessrights
    # change user to email from (pre-windows2000 name)
    #accessrights is an object - iterate
}

#export table to csv


