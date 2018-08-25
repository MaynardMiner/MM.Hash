$Path = $update.cpu.bubasik.path1
$Uri = $update.cpu.bubasik.uri

$Build = "Linux"

#Algorithms
#Yescrypt
#YescryptR16
#Lyra2z
#M7M

$Commands = [PSCustomObject]@{
    "yespower" = ''
    #"hodl" = ''
    }

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

if($CoinAlgo -eq $null)
{
$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
   if($Algorithm -eq "$($AlgoPools.(Get-Algorithm($_)).Algorithm)")
    {
     [PSCustomObject]@{
         platform = $platform
         Symbol = "$(Get-Algorithm($_))"
         MinerName = "cpuminer-CPU"
         Type = "CPU"
         Path = $Path
         Devices = $Devices
         DeviceCall = "cpuminer-opt"
         Arguments = "-a $_ -o stratum+tcp://$($AlgoPools.(Get-Algorithm($_)).Host):$($AlgoPools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4048 -u $($AlgoPools.(Get-Algorithm($_)).CPUser) -p $($AlgoPools.(Get-Algorithm($_)).CPUPass) $($Commands.$_)"
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
       platform = $platform
       Symbol = "$($CoinPools.$_.Symbol)"
       MinerName = "cpuminer-CPU"
       Type = "CPU"
       Path = $Path
       Devices = $Devices
       DeviceCall = "cpuminer-opt"
       Arguments = "-a $($CoinPools.$_.Algorithm) -o stratum+tcp://$($CoinPools.$_.Host):$($CoinPools.$_.Port) -b 0.0.0.0:4048 -u $($CoinPools.$_.CPUser) -p $($CoinPools.$_.CPUPass) $($Commands.$($CoinPools.$_.Algorithm))"
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
