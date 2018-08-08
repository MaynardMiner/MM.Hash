. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $blockpool_Request = [PSCustomObject]@{} 
 
 if($Auto_Algo -eq "Yes")
  { 
  if($Poolname -eq $Name)
   {
 try { 
     $blockpool_Request = Invoke-RestMethod "http://blockmasters.co/api/status" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "MM.Hash contacted ($Name) for a failed API check. " 
     return 
 }
 
 if (($blockpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool API had issues. " 
     return 
 } 
  
$Location = "US"

$blockpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | ForEach-Object {

    $blockpool_Algorithm = Get-Algorithm $blockpool_Request.$_.name
    $blockpool_Host = "$_.mine.blockpool.com"
    $blockpool_Port = $blockpool_Request.$_.port
    $Divisor = (1000000*$blockpool_Request.$_.mbtc_mh_factor)

  if($Algorithm -eq $blockpool_Algorithm)
      {
    if((Get-Stat -Name "$($Name)_$($blockpool_Algorithm)_Profit") -eq $null){$Stat = Set-Stat -Name "$($Name)_$($blockpool_Algorithm)_Profit" -Value ([Double]$blockpool_Request.$_.estimate_last24h/$Divisor*(1-($blockpool_Request.$_.fees/100)))}
    else{$Stat = Set-Stat -Name "$($Name)_$($blockpool_Algorithm)_Profit" -Value ([Double]$blockpool_Request.$_.estimate_current/$Divisor *(1-($blockpool_Request.$_.fees/100)))}
      }

       if($Wallet)
	{
        [PSCustomObject]@{
            Coin = "No"
            Symbol = $blockpool_Algorithm
            Mining = $blockpool_Algorithm
            Algorithm = $blockpool_Algorithm
            Price = $Stat.Live
            StablePrice = $Stat.Week
            MarginOfError = $Stat.Fluctuation
            Protocol = "stratum+tcp"
            Host = $blockpool_Host
            Port = $blockpool_Port
            User1 = $Wallet1
	    User2 = $Wallet2
            User3 = $Wallet3
            CPUser = $CPUWallet
            CPUPass = "c=$CPUcurrency,ID=$Rigname1"
            Pass1 = "c=$Passwordcurrency1,ID=$Rigname1"
            Pass2 = "c=$Passwordcurrency2,ID=$Rigname2"
	    Pass3 = "c=$Passwordcurrency3,ID=$Rigname3"
            Location = $Location
            SSL = $false
        }
     }
    }
   }
 }
