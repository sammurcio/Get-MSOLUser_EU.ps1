param( 	
  [Parameter(Mandatory=$true)]
  [string]$csv
)

$euFilter = '^Albania$|^Andorra$|^Austria$|^Belarus$|^Belgium$|^Bosnia\sand\sHerzegovina$|^Bulgaria$|^Croatia$|^Cyprus$|^Czech\sRepublic$|^Denmark$|^Estonia$|^Finland$|^France$|^Georgia$|^Germany$|^Greece$|^Hungary$|^Iceland$|^Republic\sof\sIreland$|^Italy$|^Latvia$|^Liechtenstein$|^Lithuania$|^Luxembourg$|^Republic\sof\sMacedonia$|^Malta$|^Moldova$|^Monaco$|^Montenegro$|^Netherlands$|^Norway$|^Poland$|^Portugal$|^Romania$|^Russia$|^San\sMarino$|^Serbia$|^Slovakia$|^Slovenia$|^Spain$|^Sweden$|^Switzerland$|^Turkey$|^Ukraine$|^United\sKingdom$|^Vatican$|^AL$|^AD$|^AT$|^BY$|^BE$|^BA$|^BG$|^HR$|^CY$|^CZ$|^DK$|^EE$|^FI$|^FR$|^GE$|^DE$|^GR$|^HU$|^IS$|^IE$|^IT$|^LV$|^LI$|^LT$|^LU$|^MK$|^MT$|^MD$|^MC$|^ME$|^NL$|^NO$|^PL$|^PT$|^RO$|^RU$|^SM$|^RS$|^SK$|^SI$|^ES$|^SE$|^CH$|^TR$|^UA$|^GB$|^VA$|^Ireland$|^Macedonia$|^Bosnia$|^Deutschland$'
$activity = "Processing Request..."
$status = "Getting All User Mailboxes" 

Write-Progress -Activity $activity -Status $status -ID 1
$mbxs = Get-Mailbox -Filter "RecipientTypeDetails -eq 'UserMailbox'" -ResultSize Unlimited
if ( $createddaysback ) {
  $checkDate = (Get-Date).AddDays(-$createddaysback)
  $mbxs = $mbxs | ? { $_.WhenMailboxCreated -ge $checkDate }
}
Write-Progress -Activity $activity -Status $status -ID 1 -Completed

$i = 0
$mbxCount = $mbxs.Count
foreach ( $a in $mbxs ) {
  $i++
  if ( $msolUser ) { Clear-Variable msolUser }
  $upn = $a.UserPrincipalName
  $displayName = $a.displayName
  Write-Progress -Activity "Processing mailbox list" -Status "Currently on mailbox $displayName" -PercentComplete ($i / $mbxCount * 100)
  $msolUser = Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue

  if ( !$msolUser ) {
    $result = "MSOL User Not Found"
  } elseif ( $msolUser.Country -imatch $euFilter -or $msolUser.UsageLocation -imatch $euFilter) {
    $result = "User is in EU"
  } else {
    $result = "User is not in EU"
  }

  $obj = [pscustomobject]@{
    Name = $displayName
    UserPrincipalName = $upn
    Result = $result
    Country = $msolUser.Country
    Usage_Location = $msolUser.usageLocation
    }
  
  $obj | Export-Csv -Path $csv -NoTypeInformation -Append
}

Write-Output "Results log saved here: $csv"

