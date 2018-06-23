. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
$Zpool_Request = [PSCustomObject]@{} 
 
 
 try { 
     $Zpool_Request = Invoke-RestMethod "http://www.zpool.ca/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "MM.Hash Contacted ($Name) for a failed API check. "
     return 
 } 
 
 if (($Zpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool was unreadable. " 
     return
 }     

$Location = "US"

$Zpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$Zpool_Request.$_.hashrate -gt 0} | ForEach-Object {
    $Zpool_Host = "$_.mine.zpool.ca"
    $Zpool_Port = $Zpool_Request.$_.port
    $Zpool_Algorithm = Get-Algorithm $Zpool_Request.$_.name
    $Zpool_Symbol = "$($Zpool_Algorithm)-ALGO"
    $Divisor = (1000000*$Zpool_Request.$_.mbtc_mh_factor)

 if($Algorithm -eq $Zpool_Symbol)
      {
        $Stat = Set-Stat -Name "$($Name)_$($Zpool_Symbol)_Profit" -Value ([Double]$Zpool_Request.$_.estimate_current/$Divisor*(1-($Zpool_Request.$_.fees/100)))
      }	
 

      if($Algorithm -eq $Zpool_Symbol)
      {
       if($Wallet)
	    {
        [PSCustomObject]@{
            Coin = $Zpool_Symbol
            Mining = $Zpool_Algorithm
            Algorithm = $Zpool_Algorithm
            Price = $Stat.Live
            StablePrice = $Stat.Live
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $Zpool_Host
            Port = $Zpool_Port
            User1 = $Wallet1
	        User2 = $Wallet2
            User3 = $Wallet3
            CPUser = $CPUWallet
            CPUPass = $CPUcurrency
            Pass1 = "c=$Passwordcurrency1"
            Pass2 = "c=$Passwordcurrency2"
	        Pass3 = "c=$Passwordcurrency3"
            Location = $Location
            SSL = $false
	      }
        }
     }
}
