$Path = '.\Bin\DSTM-Linux-DSTMDevices1\zm-NVIDIA1'
$Uri = 'https://github.com/MaynardMiner/MM.Compiled-Miners/releases/download/v1.0/DTSMLInux.zip'
$Build = "Zip"

if($DSTMDevices1 -ne ''){$Devices = $DSTMDevices1}
if($GPUDevices1 -ne '')
 {
  $GPUEDevices1 = $GPUDevices1 -replace ',',' '
  $Devices = $GPUEDevices1
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
            MinerName = "zm-NVIDIA1"
            Type = "NVIDIA1"
            Path = $Path
            Distro =  $Distro
            Devices = $Devices
            DeviceCall = "dstm"
            Arguments = "--server $($Pools.(Get-Algorithm($_)).Host) --port $($Pools.(Get-Algorithm($_)).Port) --user $($Pools.(Get-Algorithm($_)).User1) --pass $($Pools.(Get-Algorithm($_)).Pass1) --telemetry=0.0.0.0:42001 $($Commands.$_)"
            HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Day}
            Selected = [PSCustomObject]@{(Get-Algorithm($_)) = ""}
            API = "DSTM"
            Port = 42001
            Wrap = $false
            URI = $Uri
            BUILD = $Build
	    stats = "dstm"
          }
        }
      }

    $Pools.PSObject.Properties.Value | Where-Object {$Commands."$($_.Algorithm)" -ne $null} | ForEach {
      if("$($_.Coin)" -eq "Yes")
         {
        [PSCustomObject]@{
          Symbol = $_.Symbol
         MinerName = "zm-NVIDIA1"
         Type = "NVIDIA1"
         Path = $Path
         Devices = $Devices
         DeviceCall = "dstm"
         Arguments = "--server $($_.Host) --port $($_.Port) --user $($_.User1) --pass $($_.Pass1) --telemetry=0.0.0.0:42001 $($Commands.$($_.Algorithm))"
         HashRates = [PSCustomObject]@{$_.Symbol = $Stats."$($Name)_$($_.Symbol)_HashRate".Day}
         API = "DSTM"
         Selected = [PSCustomObject]@{$($_.Algorithm) = ""}
         Port = 42001
         Wrap = $false
         URI = $Uri
         BUILD = $Build
	 stats = "dstm"
         }
        }
       }
