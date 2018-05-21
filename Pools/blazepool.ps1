. .\Include.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $blazepool_Request = [PSCustomObject]@{} 
 
 
 try { 
     $blazepool_Request = Invoke-RestMethod "http://api.blazepool.com/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "Sniffdog contacted ($Name) for a failed API check. " 
     return 
 }
 
 if (($blazepool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool API had issues. " 
     return 
 } 
  
$Location = "US"

$blazepool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | foreach {
    $blazepool_Host = "$_.mine.blazepool.com"
    $blazepool_Port = $blazepool_Request.$_.port
    $blazepool_Algorithm = Get-Algorithm $blazepool_Request.$_.name
    $blazepool_Coin = $blazepool_Request.$_.coins
    $blazepool_Fees = $blazepool_Request.$_.fees
    $blazepool_Workers = $blazepool_Request.$_.workers

    $Divisor = 1000000
	
    switch($blazepool_Algorithm)
    {
        "equihash"{$Divisor /= 1000}
        "blake2s"{$Divisor *= 1000}
	    "yescrypt"{$Divisor /= 1000}
        "sha256"{$Divisor *= 1000}
        "sha256t"{$Divisor *= 1000}
        "blakecoin"{$Divisor *= 1000}
        "decred"{$Divisor *= 1000}
        "keccak"{$Divisor *= 1000}
        "keccakc"{$Divisor *= 1000}
        "vanilla"{$Divisor *= 1000}
    }

    if((Get-Stat -Name "$($Name)_$($blazepool_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($blazepool_Algorithm)_Profit" -Value ([Double]$blazepool_Request.$_.estimate_last24h/$Divisor*(1-($blazepoolpool_Request.$_.fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($blazepool_Algorithm)_Profit" -Value ([Double]$blazepool_Request.$_.estimate_current/$Divisor *(1-($blazepool_Request.$_.fees/100)))}
	

      if($Wallet)
	{
       [PSCustomObject]@{
            Algorithm = $blazepool_Algorithm
            Info = "$blazepool_Coin - Coin(s)"
            Price = $Stat.Live
            Fees = $blazepool_Fees
            Workers = $blazepool_Workers
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $blazepool_Host
            Port = $blazepool_Port
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
