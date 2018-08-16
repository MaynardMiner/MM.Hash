$Path = ".\Bin\EWBF-Linux-EWBFDevices2\miner-NVIDIA2"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/EWBF-Linux.zip"
$Build = "Zip"

if($EWBFDevices2 -ne ''){$Devices = $EWBFDevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
 }

#Equihash192

$Commands = [PSCustomObject]@{
  "equihash192" = '--algo 192_7 --pers auto'
  "equihash144" =  '--algo 144_5 --pers auto'
  }


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

if($CoinAlgo -eq $null)
{
$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($AlgoPools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
      Symbol = "$(Get-Algorithm($_))"
      MinerName = "miner-NVIDIA2"
      Type = "NVIDIA2"
      Path = $Path
      Devices = $Devices
      DeviceCall = "ewbf"
      Arguments = "--api 0.0.0.0:42001 --server $($AlgoPools.(Get-Algorithm($_)).Host) --port $($AlgoPools.(Get-Algorithm($_)).Port) --user $($AlgoPools.(Get-Algorithm($_)).User2) --pass $($AlgoPools.(Get-Algorithm($_)).Pass2) $($Commands.$_)"
      HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
      Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
      MinerPool = "$($AlgoPools.(Get-Algorithm($_)).Name)"
      FullName = "$($AlgoPools.(Get-Algorithm($_)).Mining)"
      API = "EWBF"
      Port = 42001
      Wrap = $false
      URI = $Uri
      BUILD = $Build
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
          Symbol = "$($Coinpools.$_.Symbol)"
           MinerName = "miner-NVIDIA2"
           Type = "NVIDIA2"
           Path = $Path
           Devices = $Devices
           DeviceCall = "ewbf"
           Arguments = "--api 0.0.0.0:42001 --server $($CoinPools.$_.Host) --port $($CoinPools.$_.Port) --user $($CoinPools.$_.User2) --pass $($CoinPools.$_.Pass2) $($Commands.$($CoinPools.$_.Algorithm))"
           HashRates = [PSCustomObject]@{$CoinPools.$_.Symbol= $Stats."$($Name)_$($CoinPools.$_.Algorithm)_HashRate".Day}
           Selected = [PSCustomObject]@{$CoinPools.$_.Algorithm = ""}
           FullName = "$($CoinPools.$_.Mining)"
           API = "EWBF"
           MinerPool = "$($CoinPools.$_.Name)"
           Port = 42001
           Wrap = $false
           URI = $Uri
           BUILD = $Build
           Algo = "$($CoinPools.$_.Algorithm)"
           }
          }
         }