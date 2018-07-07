$Path = ".\Bin\EWBF-Windows-EWBFDevices1-Algo\miner.exe"
$Uri = "https://github.com/MaynardMiner/EWB/releases/download/v1.0/EWBF.Equihash.miner.v0.3.zip"

if($EWBFDevices1 -ne ''){$Devices = $EWBFDevices1}
if($GPUDevices1 -ne '')
 {
  $GPUEDevices1 = $GPUDevices1 -replace ',',' '
  $Devices = $GPUEDevices1
 }

#Equihash192

$Commands = [PSCustomObject]@{
"ZERO" = '' #Equihash192
}


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
  {
    [PSCustomObject]@{
	    MinerName = "miner"
        Type = "NVIDIA1"
        Path = $Path
	    Distro =  $Distro
	    Devices = $Devices
        Arguments = "--algo 192_7 --pers ZERO_PoW --api 0.0.0.0:42001 --server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --user $($Pools.(Get-Algo($_)).User1) --pass $($Pools.(Get-Algo($_)).Pass1) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
        Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
        API = "EWBF"
        Port = 42001
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
    }
}
