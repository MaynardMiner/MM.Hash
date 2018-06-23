. .\IncludeCoin.ps1
 
 
 $Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $Hashrefinery_Request = [PSCustomObject]@{} 
 
 
 try { 
     $Hashrefinery_Request = Invoke-RestMethod "http://pool.hashrefinery.com/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "MM.Hash contacted ($Name) for a failed API. "
     return 
 } 
 
 
 if (($Hashrefinery_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool API was unreadable. " 
     return 
 } 
 
 
 $Location = "us" 
 
 
 $Hashrefinery_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$Hashrefinery_Request.$_.hashrate -gt 0} | ForEach-Object {
    $Hashrefinery_Host = "$_.us.hashrefinery.com"
    $Hashrefinery_Port = $Hashrefinery_Request.$_.port
    $Hashrefinery_Algorithm = Get-Algorithm $Hashrefinery_Request.$_.name
    $Hashrefinery_Symbol = "$($Hashrefinery_Algorithm)-ALGO"
    $Divisor = (1000000*$Hashrefinery_Request.$_.mbtc_mh_factor)

 if($Algorithm -eq $Hashrefinery_Symbol)
      {
        $Stat = Set-Stat -Name "$($Name)_$($Hashrefinery_Symbol)_Profit" -Value ([Double]$Hashrefinery_Request.$_.estimate_current/$Divisor*(1-($Hashrefinery_Request.$_.fees/100)))
      }	
 

      if($Algorithm -eq $Hashrefinery_Symbol)
      {
       if($Wallet)
	    {
        [PSCustomObject]@{
            Coin = $Hashrefinery_Symbol
            Mining = $Hashrefinery_Algorithm
            Algorithm = $Hashrefinery_Algorithm
            Price = $Stat.Live
            StablePrice = $Stat.Live
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $Hashrefinery_Host
            Port = $Hashrefinery_Port
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
