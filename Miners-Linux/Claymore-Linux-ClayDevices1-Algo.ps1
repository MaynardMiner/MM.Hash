$Path = '.\Bin\Claymore-Linux-ClayDevices1-Algo\ethdcrminer64'
$Uri = 'https://github.com/MaynardMiner/ClaymoreMM/releases/download/untagged-e429eb3ca9b1c5f08ae6/ClaymoreLinux.zip'
$Distro = "Linux-Claymore"
$Build = "Zip"

if($ClayDevices1 -ne ''){$Devices = $ClayDevices1}
if($GPUDevices1 -ne '')
 {
  $GPUEDevices1 = $GPUDevices1 -replace ',',''
  $Devices = $GPUEDevices1
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
	        MinerName = "ethdcrminer64"
                Type = "NVIDIA1"
                Path = $Path
                Distro =  $Distro
                Devices = $Devices
                Arguments = "-mport -3333 -mode 1 -allcoins 1 -allpools 1 -epool $($Pools.(Get-Algo($_)).Protocol)://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -ewal $($Pools.(Get-Algo($_)).User1) -epsw $($Pools.(Get-Algo($_)).Pass1) -wd 0 -dbg -1 -eres 1 $($Commands.$_)"
                HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
                Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
                API = "claymore"
                Port = 3333
                Wrap = $false
                URI = $Uri
                BUILD = $Build
          }
        }
    }
