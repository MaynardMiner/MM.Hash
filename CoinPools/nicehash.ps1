. .\IncludeCoin.ps1

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName 
 
 
 $nicehash_Request = [PSCustomObject]@{} 
 
 
 try { 
     $nicehash_Request = Invoke-RestMethod "https://api.nicehash.com/api?method=simplemultialgo.info" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop 
 } 
 catch { 
     Write-Warning "MM.Hash contacted ($Name) for a failed API. "
     return 
 }
 
 if (($nicehash_Request | Get-Member -MemberType NoteProperty -ErrorAction Ignore | Measure-Object Name).Count -le 1) { 
     Write-Warning "MM.Hash contacted ($Name) but ($Name) Pool API had issues. " 
     return 
 } 
  
 if($Location -eq "US")
  {
    $Region = "usa"
    $Location = "US"
  }

 if($Location -eq "ASIA")
  {
    $Region = "hk"
    $Location = "ASIA"
  }

if($Location -eq "EUROPE")
 {
   $Region = "eu"
   $Location = "EUROPE" 
 }

$nicehash_Request.result | Select-Object -ExpandProperty simplemultialgo | ForEach-Object {
    $nicehash_Host = "$($_.name).$Region.nicehash.com"
    $nicehash_Port = $_.port
    $nicehash_Algorithm = Get-Algorithm $_.name
    $nicehash_Fees = $Nicehash_Fee
    $nicehash_Symbol = "$($nicehash_Algorithm)-ALGO"
    $Divisor = 1000000000

 if($Algorithm -eq $nicehash_Symbol)
      {
        $Stat = Set-Stat -Name "$($Name)_$($nicehash_Symbol)_Profit" -Value ([Double]$_.paying/$Divisor*(1-($Nicehash_Fees/100)))
      }	
 

      if($Algorithm -eq $nicehash_Symbol)
      {
       if($Wallet)
	    {
       if($Nicehash_Wallet1 -ne '' -or $Nicehash_Wallet2 -ne '' -or $Nicehash_Wallet3 -ne '')
        {  
        [PSCustomObject]@{
            Coin = $nicehash_Symbol
            Mining = $nicehash_Algorithm
            Algorithm = $nicehash_Algorithm
            Price = $Stat.Live
            Fees = $nicehash_Fees
            Workers = $nicehash_Workers
            StablePrice = $Stat.Live
            Protocol = "stratum+tcp"
            Host = $nicehash_Host
            Port = $nicehash_Port
            User1 = $Nicehash_Wallet1
	          User2 = $Nicehash_Wallet2
            User3 = $Nicehash_Wallet3
            CPUser = $Nicehash_Wallet1
            CPUPass = "x"
            Pass1 = "x"
            Pass2 = "x"
	          Pass3 = "x"
            Location = $Location
            SSL = $false
	      }
        }
     }
   }
}
