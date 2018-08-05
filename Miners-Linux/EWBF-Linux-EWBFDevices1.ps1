$Path = ".\Bin\EWBF-Linux-EWBFDevices1\miner-NVIDIA1"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/EWBF-Linux.zip"
$Build = "Zip"

if($EWBFDevices1 -ne ''){$Devices = $EWBFDevices1}
if($GPUDevices1 -ne '')
 {
  $GPUEDevices1 = $GPUDevices1 -replace ',',' '
  $Devices = $GPUEDevices1
 }

#Equihash192

$Commands = [PSCustomObject]@{
  "Equihash192" = '--algo 192_7 --pers ZERO_PoW' #Equihash192
  "Equihash144xsg" =  '--algo 144_5 --pers sngemPoW'
  "Equihash144btcz" = '--algo 144_5 --pers BitcoinZ'
  "Equihash144zel" = '--algo 144_5 --pers ZelProof'
  "Equihash-BTG" = '--algo 144_5 --pers BgoldPoW'
  "Equihash144safe" = '--algo 144_5 --pers Safecoin' 
  }

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
      Symbol = (Get-Algorithm($_))
      MinerName = "miner-NVIDIA1"
      Type = "NVIDIA1"
      Path = $Path
      Devices = $Devices
      DeviceCall = "ewbf"
      Arguments = "--api 0.0.0.0:42000 --server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --user $($Pools.(Get-Algorithm($_)).User1) --pass $($Pools.(Get-Algorithm($_)).Pass1) $($Commands.$_)"
      HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
      Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
      MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
      API = "EWBF"
      Port = 42000
      Wrap = $false
      URI = $Uri
      BUILD = $Build
    Algo = "$($_)"
      }
    }
  }

