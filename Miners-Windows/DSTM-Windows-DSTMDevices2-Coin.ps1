$Path = '.\Bin\DSTM-Windows-DTSMDevices2-Coin\zm.exe'
$Uri = 'https://github.com/MaynardMiner/dtsm/releases/download/untagged-ac8fc2a2818d28fb9b06/DTSMWin.zip'
$Distro = "Windows"
$Build = "Zip"

if($DSTMDevices2 -ne ''){$Devices = $DSTMDevices2}
if($GPUDevices2 -ne '')
 {
  $GPUEDevices2 = $GPUDevices2 -replace ',',' '
  $Devices = $GPUEDevices2
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
                Type = "NVIDIA2"
                Path = $Path
                Distro =  $Distro
                Devices = $Devices
                Arguments = "--server $($Pools.$_.Host) --port $($Pools.$_.Port) --user $($Pools.$_.User2) --pass $($Pools.$_.Pass2) --telemetry=0.0.0.0:42002 $($Commands.$_)"
                HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
                Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
                API = "DSTM"
                Port = 42002
                Wrap = $false
                URI = $Uri
                BUILD = $Build
          }
        }
    }
