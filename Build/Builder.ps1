. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $zergpool_Request = [PSCustomObject]@{} 
 
 
 try { 
     $zergpool_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/currencies" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
     #$ZergpoolCoins_Request = Invoke-RestMethod "http://api.zergpool.com:8080/api/currencies" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
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
$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | ForEach-Object {
#$zergpool_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Select-Object -ExpandProperty Name | Where-Object {$zergpool_Request.$_.hashrate -gt 0} | foreach {
    $zergpool_Coin = $_
    $zergpool_Port = $zergpool_Request.$_.port
    $zergpool_Algorithm = $zergpool_Request.$_.algo
    $zergpool_Fees = $zergpool_Request.$_.fees
    $zergpool_Workers = $zergpool_Request.$_.workers
    $zergpool_Host = "$zergpool_Algorithm.mine.zergpool.com"
    $zergpool_Auto = $zergpool_Request.$_.noautotrade

    
      if($zergpool_Algorithm -eq "myr-gr")
       {
    Write-Host "`"$zergpool_Coin`" = '' #Phi"
       }
     

}


