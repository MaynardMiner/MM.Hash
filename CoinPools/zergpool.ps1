. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName


 $zergpool_Request = [PSCustomObject]@{}


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

$Location = 'US'

$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$Algorithm -eq $zergpool_Request.$_.algo} | Where-Object {$zergpool_Request.$_.hashrate -ne "0"} | Where-Object {$zergpool_Request.$_.noautotrade -eq "0"} | Where-Object {$zergpool_Request.$_.estimate -ne "0.00000"} | ForEach-Object {
#$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$zergpool_Request.$_.hashrate -gt 0} | foreach {

    $zergpool_Coin = $_
    $zergpool_Port = $zergpool_Request.$_.port
    $zergpool_Algorithm = $zergpool_Request.$_.algo
    $zergpool_Host = "$zergpool_Algorithm.mine.zergpool.com"
    $zergpool_Fees = .5
    $zergpool_CoinName = $zergpool_Request.$_.name
    $zergpool_Estimate = [Double]$zergpool_Request.$_.estimate*.001
    $zergpool_Hashrate = $zergpool_Request.$_.hashrate
    $Divisor = (1000000*$zergpool_Request.$_.mbtc_mh_factor)

    if($Algorithm -eq $zergpool_Algorithm)
      {
        $Stat = Set-Stat -Name "$($Name)_$($zergpool_Coin)_Profit" -Value ([Double]$zergpool_Estimate/$Divisor*(1-($zergpool_Fees/100)))
      }

    if($Algorithm -eq $zergpool_Algorithm)
     {
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
            Coin = $zergpool_Coin
            Mining = $zergpool_CoinName
            Algorithm = $zergpool_Algorithm
            Price = $Stat.Live
            StablePrice = $Stat.Live
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
