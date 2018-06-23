$Path = '.\Bin\DSTM-Windows-DTSMDevices1-Algo\zm.exe'
$Uri = 'https://github.com/MaynardMiner/dtsm/releases/download/untagged-ac8fc2a2818d28fb9b06/DTSMWin.zip'
$Distro = "Windows"
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
       if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
        {
        [PSCustomObject]@{
            MinerName = "zm"
                Type = "NVIDIA1"
                Path = $Path
                Distro =  $Distro
                Devices = $Devices
                Arguments = "--server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --user $($Pools.(Get-Algo($_)).User1) --pass $($Pools.(Get-Algo($_)).Pass1) --telemetry=0.0.0.0:42001 $($Commands.$_)"
                HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
                Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
                API = "DSTM"
                Port = 42001
                Wrap = $false
                URI = $Uri
                BUILD = $Build
          }
        }
    }
