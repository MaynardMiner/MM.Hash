$Path = ".\Bin\EWBF-Windows-EWBFDevices3-Algo\miner.exe"
$Uri = "https://github.com/MaynardMiner/EWB/releases/download/v1.0/EWBF.Equihash.miner.v0.3.zip"

if($EWBFDevices3 -ne ''){$Devices = $EWBFDevices3}
if($GPUDevices3 -ne '')
 {
  $GPUEDevices3 = $GPUDevices3 -replace ',',' '
  $Devices = $GPUEDevices3
 }

#Equihash192

$Commands = [PSCustomObject]@{
"equihash192" = '' #Equihash192
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
 if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
  {
    [PSCustomObject]@{
	    MinerName = "miner"
        Type = "NVIDIA3"
        Path = $Path
	    Distro =  $Distro
	    Devices = $Devices
        Arguments = "--algo 192_7 --pers ZERO_PoW --api 0.0.0.0:42003 --server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --user $($Pools.(Get-Algo($_)).User3) --pass $($Pools.(Get-Algo($_)).Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
        Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
        API = "EWBF"
        Port = 42003
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
    }
}
