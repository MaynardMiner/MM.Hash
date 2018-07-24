$Path = '.\Bin\DSTM-Linux-DSTMDevices2\zm-NVIDIA2'
$Uri = 'https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/DTSMLInux.zip'
$Build = "Zip"

if($DSTMDevices2 -ne ''){$Devices = $DSTMDevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
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
            MinerName = "zm-NVIDIA2"
            Type = "NVIDIA2"
            Path = $Path
            Devices = $Devices
            DeviceCall = "dstm"
            Arguments = "--server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --user $($Pools.(Get-Algorithm($_)).User2) --pass $($Pools.(Get-Algorithm($_)).Pass2) --telemetry=0.0.0.0:43001 $($Commands.$_)"
            HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
            Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
            API = "DSTM"
            Port = 43001
	    MinerPool = "$($Pools.(Get-Algorithm($_)).Name)"
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
         MinerName = "zm-NVIDIA2"
         Type = "NVIDIA2"
         Path = $Path
         Devices = $Devices
         DeviceCall = "dstm"
         Arguments = "--server $($_.Host) --port $($_.Port) --user $($_.User2) --pass $($_.Pass2) --telemetry=0.0.0.0:43001 $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "DSTM"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
         Port = 43001
         Wrap = $false
         URI = $Uri
         BUILD = $Build
         }
        }
       }
