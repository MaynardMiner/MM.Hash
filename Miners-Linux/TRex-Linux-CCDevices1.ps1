$Path = ".\Bin\TRex-Linux-CCDevices1\t-rex-NVIDIA1"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/TRex-Linux-9-1.zip"
$Build = "Zip"

if($RexDevices1 -ne ''){$Devices = $RexDevices1}
if($GPUDevices1 -ne ''){$Devices = $GPUDevices1}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands = [PSCustomObject]@{
"lyra2z" = '-l HashRate.log'
"tribus" = '-l HashRate.log'
"phi" = '-l HashRate.log'
"phi2" = '-l HashRate.log'
"c11" = '-l HashRate.log'
"hsr" = '-l HashRate.log'
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
   {
        [PSCustomObject]@{
        Symbol = (Get-Algorithm($_))
        MinerName = "t-rex-NVIDIA1"
	Type = "NVIDIA1"
        Path = $Path
        Devices = $Devices
        DeviceCall = "trex"
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4068 -u $($Pools.(Get-Algorithm($_)).User1) -p $($Pools.(Get-Algorithm($_)).Pass1) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
	Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
	Port = 4068
        API = "TRex"
        Wrap = $false
        URI = $Uri
        BUILD = $Build
	Algorithm = $($Pools.(Get-Algorithm($_)).Algorithm)
        }
      }
    }

$Pools.PSObject.Properties.Value | Where-Object {$Commands."$($_.Algorithm)" -ne $null} | ForEach {
        if("$($_.Coin)" -eq "Yes")
        {
        [PSCustomObject]@{
         Symbol = $_.Symbol
         MinerName = "t-rex-NVIDIA1"
         Type = "NVIDIA1"
         Path = $Path
         Devices = $Devices
         DeviceCall = "trex"
         Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4068 -u $($_.User1) -p $($_.Pass1) $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "TRex"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
	 MinerPool = "$($Pools.$_.Name)"
         Port = 4068
         Wrap = $false
         URI = $Uri
         BUILD = $Build
	 Algorithm = $($_.Algorithm)
         }
        }
       }
