param ([string] $UName, $PWord, $CUser)

$o365user = $UName
$o365pass = $PWord
$pass = convertto-securestring -string $o365pass -asplaintext -force
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist $o365user,$pass

$UserCredential = Get-Credential $mycred
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking -AllowClobber

$UserMailboxStats = Get-Mailbox -Identity $CUser | Get-MailboxStatistics
$UserMailboxStats | Add-Member -MemberType ScriptProperty -Name TotalItemSizeInBytes -Value {$this.TotalItemSize -replace "(.*\()|,| [a-z]*\)", ""} 
$UserDetails = $UserMailboxStats | Select-Object DisplayName, @{Name="TotalItemSizeInGB"; Expression={[math]::Round($_.TotalItemSizeInBytes/1GB,2)}}

$SizeCheck = $UserDetails.TotalItemSizeInGB -gt 5
$Name = $UserDetails.DisplayName
$CurrentSize = $UserDetails.TotalItemSizeInGB

$hash = [ordered]@{
        SizeCheck   = $SizeCheck
        UserName        = $Name
        CurrentSize = $CurrentSize
        }
        $object = New-Object psobject -Property $hash
        $Create += $object

Remove-PSSession $Session

return $Create