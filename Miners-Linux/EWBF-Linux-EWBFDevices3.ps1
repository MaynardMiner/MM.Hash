$Path = ".\Bin\EWBF-Linux-EWBFDevices3\miner-NVIDIA3"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/EWBF_Equihash_miner_v0.zip"
$Build = "Zip"

if($EWBFDevices3 -ne ''){$Devices = $EWBFDevices3}
if($GPUDevices3 -ne '')
 {
  $GPUEDevices3 = $GPUDevices3 -replace ',',' '
  $Devices = $GPUEDevices3
 }

#Equihash192

$Commands = [PSCustomObject]@{
  "Equihash192" = '--algo 192_7 --pers ZERO_PoW' #Equihash192
  "Equihash144" =  '--algo 144_5 --pers sngemPoW'
  "Equihash144btcz" = '--algo 144_5 --pers BitcoinZ'
  "Equihash144zel" = '--algo 144_5 --pers ZelProof'
  }


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
  {
    [PSCustomObject]@{
      Symbol = (Get-Algorithm($_))
	    MinerName = "miner-NVIDIA3"
        Type = "NVIDIA3"
        Path = $Path
	      Distro =  $Distro
        Devices = $Devices
        DeviceCalle = "ewbf"
        Arguments = "--api 0.0.0.0:42003 --server $($Pools.$_.Host) --port $($Pools.$_.Port) --user $($Pools.$_.User3) --pass $($Pools.$_.Pass3) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Day}
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
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
        Symbol = $_.Symbol
        MinerName = "miner-NVIDIA3"
        Type = "NVIDIA3"
        Path = $Path
        Devices = $Devices
        DeviceCall = "ewbf"
        Arguments = "--api 0.0.0.0:42003 --server $($_.Host) --port $($_.Port) --user $($_.User3) --pass $($_.Pass3) $($Commands.$($_.Algorithm))"
        HashRates = [PSCustomObject]@{$_.Symbol= $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
        Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
	 MinerPool = "$($_.Name)"
        API = "EWBF"
        Port = 42003
        Wrap = $false
        URI = $Uri
        BUILD = $Build
       }
      }
     }
  
