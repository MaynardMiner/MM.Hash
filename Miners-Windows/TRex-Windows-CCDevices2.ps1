$Path = ".\Bin\TRex-Windows-CCDevices2\t-rex.exe"
$Uri = "https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v2.0/t-rex-Windows.zip"
$Build = "Zip"

if($RexDevices2 -ne ''){$Devices = $RexDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands = [PSCustomObject]@{
"c11" = ''
"hsr" = ''
"tribus" = ''
}


$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
   {
        [PSCustomObject]@{
        Symbol = (Get-Algorithm($_))
        MinerName = "t-rex-NVIDIA2"
	Type = "NVIDIA2"
        Path = $Path
        Devices = $Devices
        DeviceCall = "trex"
        Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algorithm($_)).Host):$($Pools.(Get-Algorithm($_)).Port) -b 0.0.0.0:4069 -u $($Pools.(Get-Algorithm($_)).User2) -p $($Pools.(Get-Algorithm($_)).Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
	Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
	Port = 4069
        API = "ccminer"
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
         MinerName = "t-rex-NVIDIA2"
         Type = "NVIDIA2"
         Path = $Path
         Devices = $Devices
         DeviceCall = "trex"
         Arguments = "-a $($_.Algorithm) -o stratum+tcp://$($_.Host):$($_.Port) -b 0.0.0.0:4069 -u $($_.User2) -p $($_.Pass2) $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "ccminer"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
	MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
         Port = 4069
         Wrap = $false
         URI = $Uri
         BUILD = $Build
         }
        }
       }
