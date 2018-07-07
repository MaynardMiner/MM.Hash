$Path = ".\Bin\EWBF-Windows-EWBFDevices2-Algo\miner.exe"
$Uri = "https://github.com/MaynardMiner/EWB/releases/download/v1.0/EWBF.Equihash.miner.v0.3.zip"

if($EWBFDevices2 -ne ''){$Devices = $EWBFDevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
 }

#Equihash192

$Commands = [PSCustomObject]@{
"Equihash192" = '' #Equihash192
}


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
  {
    [PSCustomObject]@{
	    MinerName = "miner"
        Type = "NVIDIA2"
        Path = $Path
	    Distro =  $Distro
	    Devices = $Devices
        Arguments = "--algo 192_7 --pers ZERO_PoW --api 0.0.0.0:42002 --server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --user $($Pools.(Get-Algo($_)).User2) --pass $($Pools.(Get-Algo($_)).Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
        Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
        API = "EWBF"
        Port = 42002
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
    }
 }