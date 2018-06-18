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
        "quark"{$Divisor *= 1000}
	"Nist5"{$Divisor *= 1000}
	"Skein"{$Divisor *= 1000}
    }


    if($Algorithm -eq $zergpool_Algorithm)
      {
        $Stat = Set-Stat -Name "$($Name)_$($zergpool_Coin)_Profit" -Value ([Double]$zergpool_Estimate/$Divisor*(1-($zergpool_Fees/100)))
      }

    if($Algorithm -eq $zergpool_Algorithm)
     {
      if($Wallet1)
       {
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
            User1 = $Wallet1
	        User2 = $Wallet2
	        User3 = $Wallet3
            Pass1 = "c=$Passwordcurrency1,mc=$zergpool_Coin"
            Pass2 = "c=$Passwordcurrency2,mc=$zergpool_Coin"
	        Pass3 = "c=$Passwordcurrency3,mc=$zergpool_Coin"
            Location = $Location
            SSL = $false
	       }
        }
    }
 }
