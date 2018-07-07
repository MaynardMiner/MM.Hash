$Path = ".\Bin\EWBF-Windows-EWBFDevices2-Coin\miner.exe"
$Uri = "https://github.com/MaynardMiner/EWB/releases/download/v1.0/EWBF.Equihash.miner.v0.3.zip"

if($EWBFDevices2 -ne ''){$Devices = $EWBFDevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
 }

#Equihash192

$Commands = [PSCustomObject]@{
"ZER" = '' #Equihash192
}


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.$_.Algorithm)")
  {
    [PSCustomObject]@{
	    MinerName = "miner"
        Type = "NVIDIA2"
        Path = $Path
	      Distro =  $Distro
	      Devices = $Devices
        Arguments = "--algo 192_7 --pers ZERO_PoW --api 0.0.0.0:42002 --server $($Pools.$_.Host) --port $($Pools.$_.Port) --user $($Pools.$_.User2) --pass $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        API = "EWBF"
        Port = 42002
        Wrap = $false
        URI = $Uri
        BUILD = $Build
      }
    }
}
