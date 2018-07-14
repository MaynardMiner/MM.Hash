. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName


 $zergpool_Request = [PSCustomObject]@{}

if($Auto_Coin -eq "Yes")
 {
 try {
     $zergpool_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/currencies" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
     #$ZergpoolAlgo_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
 }
 catch {
     Write-Warning "MM.Hash contacted ($Name) for a failed API check. "
     return
 }

 if (($zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) {
     Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool API was unreadable. "
     return
  }
 }

if($Auto_Algo -eq "Yes")
{
    try {
        $ZergpoolAlgo_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    }
    catch {
        Write-Warning "MM.Hash contacted ($Name) for a failed API check. "
        return
    }
   
    if (($zergpoolAlgo_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) {
        Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool API was unreadable. "
        return
     }
 }


$Location = 'US'

if($Auto_Coin -eq "Yes")
 {
$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$Algorithm -eq $zergpool_Request.$_.algo} | Where-Object {$zergpool_Request.$_.hashrate -ne "0"} | Where-Object {$zergpool_Request.$_.noautotrade -eq "0"} | Where-Object {$zergpool_Request.$_.estimate -ne "0.00000"} | ForEach-Object {

    $zergpool_Coin = $_
    $zergpool_Symbol = $_
    switch ($zergpool_Symbol) {
     "HSR"{$zergpool_Symbol = "HSR-Coin"}
     "SIB"{$zergpool_Symbol = "SIB-Coin"}
     '$PAC'{$zergpool_Symbol = "PAC-Coin"}
    }
    $zergpool_Port = $zergpool_Request.$_.port
    $zergpool_Algorithm = Get-Algorithm $zergpool_Request.$_.algo
    $zergpool_Host = "$($zergpool_Request.$_.algo).mine.zergpool.com"
    $zergpool_Fees = .5
    $zergpool_CoinName = $zergpool_Request.$_.name
    $zergpool_Estimate = [Double]$zergpool_Request.$_.estimate*.001
    $zergpool_Hashrate = $zergpool_Request.$_.hashrate
    $zergpool_24h= "24h_btc"
    $Divisor = (1000000*$zergpool_Request.$_.mbtc_mh_factor)

    if($Algorithm -eq $zergpool_Algorithm)
      {
      if($PoolName -eq $Name)
       {
    if((Get-Stat -Name "$($Name)_$($zergpool_Symbol)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($zergpool_Symbol)_Profit" -Value ([Double]$zergpool_Request.$_.$($zergpool_24h)/$Divisor*(1-($zergpool_fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($zergpool_Symbol)_Profit" -Value ([Double]$zergpool_Estimate/$Divisor *(1-($zergpool_fees/100)))}
      }
     }
     
      if($Wallet)
       {
        If($ZergpoolWallet1 -ne ''){$ZergWallet1 = $ZergpoolWallet1}
        else{$ZergWallet1 = $Wallet1}
        if($ZergpoolWallet2 -ne ''){$ZergWallet2 = $ZergpoolWallet2}
        else{$ZergWallet2 = $Wallet2}
        if($ZergpoolWallet1 -ne ''){$ZergWallet3 = $ZergpoolWallet3}
        else{$ZergWallet3 = $Wallet3}
        if($Zergpoolpassword1 -ne ''){$Zergpass1 = $Zergpoolpassword1}
        else{$Zergpass1 = $Passwordcurrency1}
        if($Zergpoolpassword2 -ne ''){$Zergpass2 = $Zergpoolpassword2}
        else{$Zergpass2 = $Passwordcurrency2}
        if($Zergpoolpassword3 -ne ''){$Zergpass3 = $Zergpoolpassword3}
        else{$Zergpass3 = $Passwordcurrency3}
        [PSCustomObject]@{
            Coin = "Yes"
            Symbol = $zergpool_Symbol
            Mining = $zergpool_CoinName
            Algorithm = $zergpool_Algorithm
            Price = $Stat.Live
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $zergpool_Host
            Port = $zergpool_Port
            User1 = $ZergWallet1
	        User2 = $ZergWallet2
            User3 = $ZergWallet3
            CPUser = $CPUWallet
            CPUPass = "c=$CPUcurrency,mc=$zergpool_Coin"
            Pass1 = "c=$Zergpass1,mc=$zergpool_Coin"
            Pass2 = "c=$Zergpass2,mc=$zergpool_Coin"
	        Pass3 = "c=$Zergpass3,mc=$zergpool_Coin"
            Location = $Location
            SSL = $false
        }
    }
  }
 }


 if($Auto_Algo -eq "Yes")
 {
 $zergpoolAlgo_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$Algorithm -eq $zergpoolAlgo_Request.$_.name} | Where-Object {$zergpoolAlgo_Request.$_.hashrate -ne "0"} | Where-Object {$zergpoolAlgo_Request.$_.estimate_current -ne "0.00000"} | ForEach-Object {
    
        $zergpoolAlgo_Algorithm = Get-Algorithm $zergpoolAlgo_Request.$_.name
        $zergpoolAlgo_Host = "$_.mine.zergpool.com"
        $zergpoolAlgo_Port = $zergpoolAlgo_Request.$_.port
        $Divisor = (1000000*$zergpoolAlgo_Request.$_.mbtc_mh_factor)

        if($Algorithm -eq $zergpoolAlgo_Algorithm)
          {
          if($PoolName -eq $Name)
           {
        if((Get-Stat -Name "$($Name)_$($zergpoolAlgo_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($zergpoolAlgo_Algorithm)_Profit" -Value ([Double]$zergpoolAlgo_Request.$_.estimate_last24h/$Divisor*(1-($zergpoolAlgo_Request.$_.fees/100)))}
        else{$Stat = Set-Stat -Name "$($Name)_$($zergpoolAlgo_Algorithm)_Profit" -Value ([Double]$zergpoolAlgo_Request.$_.Estimate_Current/$Divisor *(1-($zergpoolAlgo_Request.$_.fees/100)))}
          }
         }
         
          if($Wallet)
           {
            If($ZergpoolWallet1 -ne ''){$ZergWallet1 = $ZergpoolWallet1}
            else{$ZergWallet1 = $Wallet1}
            if($ZergpoolWallet2 -ne ''){$ZergWallet2 = $ZergpoolWallet2}
            else{$ZergWallet2 = $Wallet2}
            if($ZergpoolWallet1 -ne ''){$ZergWallet3 = $ZergpoolWallet3}
            else{$ZergWallet3 = $Wallet3}
            if($Zergpoolpassword1 -ne ''){$Zergpass1 = $Zergpoolpassword1}
            else{$Zergpass1 = $Passwordcurrency1}
            if($Zergpoolpassword2 -ne ''){$Zergpass2 = $Zergpoolpassword2}
            else{$Zergpass2 = $Passwordcurrency2}
            if($Zergpoolpassword3 -ne ''){$Zergpass3 = $Zergpoolpassword3}
            else{$Zergpass3 = $Passwordcurrency3}
            [PSCustomObject]@{
                Coin = "No"
                Symbol = $zergpoolAlgo_Algorithm
                Mining = $zergpoolAlgo_Algorithm
                Algorithm = $zergpoolAlgo_Algorithm
                Price = $Stat.Live
                StablePrice = $Stat.Week
                MarginOfError = $Stat.Fluctuation
                Protocol = "stratum+tcp"
                Host = $zergpoolAlgo_Host
                Port = $zergpoolAlgo_Port
                User1 = $ZergWallet1
                User2 = $ZergWallet2
                User3 = $ZergWallet3
                CPUser = $CPUWallet
                CPUPass = "c=$CPUcurrency,ID=$Rigname1"
                Pass1 = "c=$Zergpass1,ID=$Rigname1"
                Pass2 = "c=$Zergpass2,ID=$Rigname2"
                Pass3 = "c=$Zergpass3,ID=$Rigname3"
                Location = $Location
                SSL = $false
            }
        }
      }
     }
    
