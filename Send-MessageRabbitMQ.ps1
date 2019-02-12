#Sources
#http://ramblingcookiemonster.github.io/RabbitMQ-Intro/
<#
$RabbitMQCred = Get-Credential -Message "Account for Rabbit MQ Server" -UserName "Collab_Admin"
$RabbitMQCred | Select Username,@{Name="Password";Expression = {$_.password | ConvertFrom-SecureString}} | ConvertTo-Json | Out-File .\testcredentials.json #>

#Define a default RabbitMq server and get a credential to use
Set-RabbitMqConfig -ComputerName 'de0-vsiaas-1223.eu.airbus.corp'

$in = Get-Content -Path '.\testcredentials.json' | Out-String | ConvertFrom-Json
$login = $in.Username
$password = ConvertTo-SecureString $in.Password
$RabbitMQCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($login,$password)

#Set some common parameters we will always use:
$Params = @{
    Credential = $RabbitMQCred
}

#Assumes an exchange and bound queue set up per RabbitMqTools example:
$ExchangeName = "migration" 
$QueueName = "Mig_CM"

$object = [pscustomobject]@{
    Some='Random CM message'
    Data = $(Get-Date)
}

#Open a new PowerShell Window import PSRabbitMq, and send a persistent message
Send-RabbitMqMessage -Exchange $ExchangeName -Key $QueueName -InputObject "Test from json cred" -vhost /collab @Params

#Start Listener Rabbit MQ
#Start-RabbitMqListener @params -Exchange "migration" -QueueName "Mig_CM" -vhost /collab