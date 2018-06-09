. .\Include.ps1

try
{
    $MineMoney_Request = Invoke-WebRequest "https://www.minemoney.co/api/status" -UseBasicParsing -Headers @{"Cache-Control"="no-cache"} | ConvertFrom-Json } catch { return }

if(-not $MineMoney_Request){return}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Location = "US"

$MineMoney_Request | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    $MineMoney_Host = "$_.minemoney.co"
    $MineMoney_Port = $MineMoney_Request.$_.port
    $MineMoney_Algorithm = Get-Algorithm $MineMoney_Request.$_.name
    $MineMoney_Coin = $MineMoney_Request.$_.coins
    $MineMoney_Fees = $MineMoney_Request.$_.fees
    $MineMoney_Workers = $MineMoney_Request.$_.workers

    $Divisor = 1000000
	
    switch ($MineMoney_Algorithm) {
        "blake2s" {$Divisor *= 1000}
	    "blakecoin" {$Divisor *= 1000}
        "decred" {$Divisor *= 1000}
	    "keccak" {$Divisor *= 1000}
    }

    if((Get-Stat -Name "$($Name)_$($MineMoney_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($MineMoney_Algorithm)_Profit" -Value ([Double]$MineMoney_Request.$_.estimate_last24h/$Divisor*(1-($MineMoney_Request.$_.fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($MineMoney_Algorithm)_Profit" -Value ([Double]$MineMoney_Request.$_.estimate_current/$Divisor *(1-($MineMoney_Request.$_.fees/100)))} 
	
    if($Wallet)
    {
        [PSCustomObject]@{
            Algorithm = $MineMoney_Algorithm
            Info = "$MineMoney_Coin - Coin(s)"
            Price = $Stat.Live
            Fees = $MineMoney_Fees
            StablePrice = $Stat.Week
            Workers = $MineMoney_Workers
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $MineMoney_Host
            Port = $MineMoney_Port
            User = $Wallet
	    User1 = $Wallet1
	    User2 = $Wallet2
	    User3 = $Wallet3
	    User4 = $Wallet4
	    User5 = $Wallet5
	    User6 = $Wallet6
	    User7 = $Wallet7
	    User8 = $Wallet8
	    Pass = "ID=$RigName,c=$Passwordcurrency"
            Pass1 = "ID=$RigName,c=$Passwordcurrency1"
	    Pass2 = "ID=$RigName,c=$Passwordcurrency2"
	    Pass3 = "ID=$RigName,c=$Passwordcurrency3"
	    Pass4 = "ID=$RigName,c=$Passwordcurrency4"
	    Pass5 = "ID=$RigName,c=$Passwordcurrency5"
	    Pass6 = "ID=$RigName,c=$Passwordcurrency6"
	    Pass7 = "ID=$RigName,c=$Passwordcurrency7"
	    Pass8 = "ID=$RigName,c=$Passwordcurrency8"
            Location = $Location
            SSL = $false
        }
    }
}
