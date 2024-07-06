Import-Module C:\Github Projects\Powershell\MailModule.psm1
$MailAccount=Import-Clixml -Path C:\Github Projects\Powershell\outlook.xml
$MailPort=587
$MailSMTPServer="smtp-mail.outlook.com"
$MailFrom=$MailAccount.Username
$MailTo="mymail@outlook.com"

$ServicesFiles="C:\Github Projects\Powershell\ServicePinger\Services.csv"
$LogPath="C:\Github Projects\Powershell\ServicePinger\Logs"
$LogFile="Services -$(Get-Date -Format "yyyy-MM-dd hh-mm").txt"
$Services=Import-Csv -Path $ServicesFiles -Delimiter ','

foreach($Service in $Services){
    $CurrentServiceStatus=(Get-Service -Name $Service.Name).Status

    if($Service.Status -ne $CurrentServiceStatus){
        $Log="Service : $($Service.Name) is currently $CurrentServiceStatus, should be $($Service.Status)"
        Write-Output $Log
        Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log

        $Log="Setting $($Service.Name) to $($Service.Status)"
        Write-Output $Log 
        Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log
        Set-Service -Name $service.Name -Status $Service.Status

        $AfterServiceStatus=(Get-Service -Name $Service.Name).Status
        if($Service.Status -eq $AfterServiceStatus){
            $Log="Setting action succeeded. Service $($Service.Name) is now $AfterServiceStatus"
            Write-Output $Log
            Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log

        }else{
            $Log="Setting action failed. Service $($service.Name) is still $AfterServiceStatus, should be $($service.Status)"
            Write-Output $Log
            Out-File -FilePath "$LogPath\$LogFile" -Append -InputObject $Log

        }
    }
}

if(Test-Path -Path "$LogPath\$LogFile"){
    $Subject="$($env:COMPUTERNAME) is experiencing service issues"
    $Body="That is the file"
    $Attachment="$LogPath\$LogFile"
    Send-mailKitMessage -From $MailFrom -To $MailTo -SMTPServer $MailSMTPServer -Port $MailPort -Credential $MailAccount -Subject $Subject -Body $Body -Attachments $Attachment
}