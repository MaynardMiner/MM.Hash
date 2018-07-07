$Path = '.\Bin\DSTM-Windows-DTSMDevices3-Coin\zm.exe'
$Uri = 'https://github.com/MaynardMiner/dtsm/releases/download/untagged-ac8fc2a2818d28fb9b06/DTSMWin.zip'
$Distro = "Windows"
$Build = "Zip"

if($DSTMDevices3 -ne ''){$Devices = $DSTMDevices3}
if($GPUDevices3 -ne '')
 {
  $GPUEDevices3 = $GPUDevices3 -replace ',',' '
  $Devices = $GPUEDevices3
 }

 $Commands = [PSCustomObject]@{
    "HUSH" = ''
    "CMM" = ''
    "VOT" = ''
    }

    $Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

    $Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
       if($Algorithm -eq "$($Pools.$_.Algorithm)")
        {
        [PSCustomObject]@{
            MinerName = "zm"
                Type = "NVIDIA3"
                Path = $Path
                Distro =  $Distro
                Devices = $Devices
                Arguments = "--server $($Pools.$_.Host) --port $($Pools.$_.Port) --user $($Pools.$_.User3) --pass $($Pools.$_.Pass3) --telemetry=0.0.0.0:42003 $($Commands.$_)"
                HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
                Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
                API = "DSTM"
                Port = 42003
                Wrap = $false
                URI = $Uri
                BUILD = $Build
          }
        }
    }