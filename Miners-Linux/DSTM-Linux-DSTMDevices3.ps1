$Path = '.\Bin\DSTM-Linux-DSTMDevices3\zm-NVIDIA3'
$Uri = 'https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/DTSMLInux.zip'
$Build = "Zip"

if($DSTMDevices3 -ne ''){$Devices = $DSTMDevices3}
if($GPUDevices3 -ne '')
 {
  $GPUEDevices3 = $GPUDevices3 -replace ',',' ' 
  $Devices = $GPUEDevices3
 }

 $Commands = [PSCustomObject]@{

    "Equihash" = ''

    }


    $Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

    $Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
      if($Algorithm -eq "$($Pools.(Get-Algorithm($_)).Algorithm)")
      {
        [PSCustomObject]@{
          Symbol = (Get-Algorithm($_))
            MinerName = "zm-NVIDIA3"
            Type = "NVIDIA3"
            Path = $Path
            Devices = $Devices
            DeviceCall = "dstm"
            Arguments = "--server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --user $($Pools.(Get-Algorithm($_)).User3) --pass $($Pools.(Get-Algorithm($_)).Pass3) --telemetry=0.0.0.0:42003 $($Commands.$_)"
            HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
            Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
            API = "DSTM"
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
         MinerName = "zm-NVIDIA3"
         Type = "NVIDIA3"
         Path = $Path
         Devices = $Devices
         DeviceCall = "dstm"
         Arguments = "--server $($_.Host) --port $($_.Port) --user $($_.User3) --pass $($_.Pass3) --telemetry=0.0.0.0:42003 $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "DSTM"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
         Port = 42003
         Wrap = $false
         URI = $Uri
         BUILD = $Build
	 Stats = "dstm"
         }
        }
       }
