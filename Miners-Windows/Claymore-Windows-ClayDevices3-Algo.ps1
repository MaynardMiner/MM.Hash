$Path = '.\Bin\Claymore-Windows-ClayDevices3-Algo\EthDcrMiner64.exe'
$Uri = 'https://github.com/MaynardMiner/ClaymoreMM/releases/download/untagged-e429eb3ca9b1c5f08ae6/ClaymoreWin.zip'
$Distro = "Windows"
$Build = "Zip"

if($ClayDevices3 -ne ''){$Devices = $ClayDevices3}
if($GPUDevices3 -ne '')
 {
  $GPUEDevices3 = $GPUDevices3 -replace ',',''
  $Devices = $GPUEDevices3
 }

 $Commands = [PSCustomObject]@{
    "ethash" = '-esm 2'
    "daggerhashimoto" = '-esm 3 -estale 0'
    }

    $Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

    $Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
       if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
        {
        [PSCustomObject]@{
            MinerName = "EthDcrMiner64"
                Type = "NVIDIA3"
                Path = $Path
                Distro =  $Distro
                Devices = $Devices
                Arguments = "-mport -3335 -mode 1 -allpools 1 -epool $($Pools.(Get-Algo($_)).Protocol)://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -ewal $($Pools.(Get-Algo($_)).User3) -epsw $($Pools.(Get-Algo($_)).Pass3) -wd 0 -dbg -1 -eres 1 -y 1 $($Commands.$_)"
                HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
                Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
                API = "claymore"
                Port = 3335
                Wrap = $false
                URI = $Uri
                BUILD = $Build
          }
        }
    }
