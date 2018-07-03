. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $phiphipool_Request = [PSCustomObject]@{} 
 
 
 try { 
     $phiphipool_Request = Invoke-RestMethod "http://www.phi-phi-pool.com/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "MM.Hash Contacted ($Name) for a failed API check. " 
     return 
 }
 
 if (($phiphipool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "SniffDog sniffed near ($Name) but ($Name) Pool API had no scent. " 
     return 
 } 
  
$Location = 'Europe', 'US'
$phiphipool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | ForEach-Object {
#$phiphipool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$phiphipool_Request.$_.hashrate -gt 0} | foreach {
    $phiphipool_Host = "pool1.phi-phi-pool.com"
    $phiphipool_Port = $phiphipool_Request.$_.port
    $phiphipool_Algorithm = Get-Algorithm $phiphipool_Request.$_.name
    $phiphipool_Symbol = "$($phiphipool_Algorithm)-ALGO"
    $Divisor = (1000000*$phiphipool_Request.$_.mbtc_mh_factor)

 if($Algorithm -eq $phiphipool_Symbol)
      {
    if((Get-Stat -Name "$($Name)_$($phiphipool_Symbol)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($phiphipool_Symbol)_Profit" -Value ([Double]$phiphipool_Request.$_.estimate_last24h/$Divisor*(1-($phiphipool_Request.$_.fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($phiphipool_Symbol)_Profit" -Value ([Double]$phiphipool_Symbol.$_.estimate_current/$Divisor *(1-($phiphipool_Symbol.$_.fees/100)))}
      }	
 
       if($Wallet)
	    {
        [PSCustomObject]@{
            Symbol = $phiphipool_Symbol
            Mining = $phiphipool_Algorithm
            Algorithm = $phiphipool_Algorithm
            Price = $Stat.Live
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $phiphipool_Host
            Port = $phiphipool_Port
            User1 = $Wallet1
	        User2 = $Wallet2
            User3 = $Wallet3
            CPUser = $CPUWallet
           CPUPass = "c=$CPUcurrency"
            Pass1 = "c=$Passwordcurrency1"
            Pass2 = "c=$Passwordcurrency2"
	        Pass3 = "c=$Passwordcurrency3"
            Location = $Location
            SSL = $false
        }
     }
}
