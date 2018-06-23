$Path = '.\Bin\DSTM-Windows-DTSMDevices2-Algo\zm.exe'
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

    "Equihash" = ''
    
    }
    
    
    $Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
    
    $Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
       if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
        {
        [PSCustomObject]@{
            MinerName = "zm"
                Type = "NVIDIA2"
                Path = $Path
            Distro =  $Distro
            Devices = $Devices
                Arguments = "--server $($Pools.(Get-Algo($_)).Host) --port $($Pools.(Get-Algo($_)).Port) --user $($Pools.(Get-Algo($_)).User2) --pass $($Pools.(Get-Algo($_)).Pass2) --telemetry=0.0.0.0:42002$($Commands.$_)"
                HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
                Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
                API = "DSTM"
                Port = 42002
                Wrap = $false
                URI = $Uri
                BUILD = $Build
          }
        }
    }
    