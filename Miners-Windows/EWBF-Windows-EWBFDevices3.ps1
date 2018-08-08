$Path = ".\Bin\EWBF-Windows-EWBFDevices3-Algo\miner.exe"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v2.0/EWBF-Windows.zip"
$Build = "Zip"

if($EWBFDevices3 -ne ''){$Devices = $EWBFDevices3}
if($GPUDevices3 -ne '')
 {
  $GPUEDevices3 = $GPUDevices3 -replace ',',' '
  $Devices = $GPUEDevices3
 }

#Equihash192

$Commands = [PSCustomObject]@{
  "Equihash192" = '--algo 192_7 --pers auto'
  "Equihash144" =  '--algo 144_5 --pers auto'
  }

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
	    MinerName = "miner"
        Type = "NVIDIA3"
        Path = $Path
	      Distro =  $Distro
        Devices = $Devices
        DeviceCalle = "ewbf"
        Arguments = "--api 0.0.0.0:42003 --server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --user $($Pools.(Get-Algorithm($_)).User3) --pass $($Pools.(Get-Algorithm($_)).Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
        Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
              	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
        API = "EWBF"
        Port = 42003
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
    }
  }

$Pools.PSObject.Properties.Value | Where-Object {$Commands."$($_.Algorithm)" -ne $null} | ForEach {
        if("$($_.Coin)" -eq "Yes")
        {
        [PSCustomObject]@{
         MinerName = "miner"
         Type = "NVIDIA3"
         Path = $Path
         Devices = $Devices
         DeviceCall = "ewbf"
	 Arguments = "--api 0.0.0.0:42002 --server $($_.Host) --port $($_.Port) --user $($_.User3) --pass $($_.Pass3) $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
         API = "EWBF"
         MinerPool = "$($_.Name)"
         Port = 42002
         Wrap = $false
         URI = $Uri
         BUILD = $Build
         }
        }
       }

