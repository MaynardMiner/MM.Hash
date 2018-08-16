$Path = "./Bin/cryptozeny/cpuminer-CPU"
$Uri = "https://github.com/cryptozeny/cpuminer-kawaii.git"
$Build =  "Linux"


#Algorithms
#Yescrypt
#YescryptR16
#Lyra2z
#M7M

$Commands = [PSCustomObject]@{
    "balloon" = ''
    #"hodl" = ''
    }

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

if($CoinAlgo -eq $null)
{
$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
   if($Algorithm -eq "$($AlgoPools.(Get-Algorithm($_)).Algorithm)")
    {
     [PSCustomObject]@{
         Symbol = "$(Get-Algorithm($_))"
         MinerName = "cpuminer-CPU"
         Type = "CPU"
         Path = $Path
         Devices = $Devices
         DeviceCall = "cpuminer-opt"
         Arguments = "-a $_ -o stratum+tcp://$($AlgoPools.(Get-Algorithm($_)).Host):$($AlgoPools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4048 -u $($AlgoPools.(Get-Algorithm($_)).User1) -p $($AlgoPools.(Get-Algorithm($_)).Pass1) $($Commands.$_)"
         HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
         Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
         MinerPool = "$($AlgoPools.(Get-Algorithm($_)).Name)"
         FullName = "$($AlgoPools.(Get-Algorithm($_)).Mining)"
         Port = 4048
         API = "Ccminer"
         Wrap = $false
         URI = $Uri
         BUILD = $Build
         PoolType = "AlgoPools"
         Algo = "$($_)"
         NewAlgo = ''
         }
       }
     }
    }
else{
    $CoinPools | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name |
    Where {$($Commands.$($CoinPools.$_.Algorithm)) -NE $null} |
    foreach {
      [PSCustomObject]@{
       Symbol = "$($CoinPools.$_.Symbol)"
       MinerName = "cpuminer-CPU"
       Type = "CPU"
       Path = $Path
       Devices = $Devices
       DeviceCall = "cpuminer-opt"
       Arguments = "-a $($CoinPools.$_.Algorithm) -o stratum+tcp://$($CoinPools.$_.Host):$($CoinPools.$_.Port) -b 0.0.0.0:4048 -u $($CoinPools.$_.User1) -p $($CoinPools.$_.Pass1) $($Commands.$($CoinPools.$_.Algorithm))"
       HashRates = [PSCustomObject]@{$CoinPools.$_.Symbol= $Stats."$($Name)_$($CoinPools.$_.Algorithm)_HashRate".Day}
       API = "Ccminer"
       Selected = [PSCustomObject]@{$($CoinPools.$_.Algorithm) = ""}
       FullName = "$($CoinPools.$_.Mining)"
       MinerPool = "$($CoinPools.$_.Name)"
       Port = 4048
       Wrap = $false
       URI = $Uri
       BUILD = $Build
       PoolType = "CoinPools"
       Algo = "$($CoinPools.$_.Algorithm)"
       }
      }
     }
