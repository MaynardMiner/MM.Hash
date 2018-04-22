. .\Include.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $zergpool_Request = [PSCustomObject]@{} 
 
 
 try { 
     $Zergpool_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
     $ZergpoolCoins_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/currencies" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "Sniffdog howled at ($Name) for a failed API check. " 
     return 
 }
 
 if (($zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "SniffDog sniffed near ($Name) but ($Name) Pool API had no scent. " 
     return 
 } 
  
$Location = "US"
$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select -ExpandProperty Name | foreach {
#$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$zergpool_Request.$_.hashrate -gt 0} | foreach {
    $zergpool_Host = "mine.zergpool.com"
    $zergpool_Port = $zergpool_Request.$_.port
    $zergpool_Algorithm = Get-Algorithm $zergpool_Request.$_.name
    $zergpool_Coin = $zergpool_Request.$_.coins
    $zergpool_Fees = $zergpool_Request.$_.fees
    $zergpool_Workers = $zergpool_Request.$_.workers

    $Divisor = 1000000
	
    switch($zergpool_Algorithm)
    {
        "equihash"{$Divisor /= 1000}
        "blake2s"{$Divisor *= 1000}
        "sha256"{$Divisor *= 1000}
        "sha256t"{$Divisor *= 1000}
        "blakecoin"{$Divisor *= 1000}
        "decred"{$Divisor *= 1000}
        "keccak"{$Divisor *= 1000}
        "keccakc"{$Divisor *= 1000}
        "vanilla"{$Divisor *= 1000}
		"x11"{$Divisor *= 1000}
		"scrypt"{$Divisor *= 1000}
		"qubit"{$Divisor *= 1000}
		"yescrypt"{$Divisor /= 1000}
        		
    }

			
    if((Get-Stat -Name "$($Name)_$($zergpool_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($zergpool_Algorithm)_Profit" -Value ([Double]$zergpool_Request.$_.estimate_last24h/$Divisor*(1-($zergpool_request.$_.fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($zergpool_Algorithm)_Profit" -Value ([Double]$zergpool_Request.$_.estimate_current/$Divisor *(1-($zergpool_request.$_.fees/100)))}
	
    if($Wallet)
    {
        [PSCustomObject]@{
            Algorithm = $zergpool_Algorithm
            Info = "$zergpool_Coin - Coin(s)"
            Price = $Stat.Live
            Fees = $zergpool_Fees
            Workers = $zergpool_Workers
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $zergpool_Host
            Port = $zergpool_Port
            User = $Wallet
            User1 = $Wallet1
	        User2 = $Wallet2
	        User3 = $Wallet3
	        User4 = $Wallet4
	        User5 = $Wallet5
	        User6 = $Wallet6
            User7 = $Wallet7
            Pass = "ID=$RigName,c=$Passwordcurrency"
            Pass1 = "ID=$RigName,c=$Passwordcurrency1"
	        Pass2 = "ID=$RigName,c=$Passwordcurrency2"
	        Pass3 = "ID=$RigName,c=$Passwordcurrency3"
	        Pass4 = "ID=$RigName,c=$Passwordcurrency4"
	        Pass5 = "ID=$RigName,c=$Passwordcurrency5"
	        Pass6 = "ID=$RigName,c=$Passwordcurrency6"
	        Pass7 = "ID=$RigName,c=$Passwordcurrency7"
            Location = $Location
            SSL = $false
        }
    }
}
