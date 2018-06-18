$Path = ".\Bin\krnlx-Windows-CCDevices2-Algo\ccminer_x86.exe"
$Uri = "https://github.com/MaynardMiner/Window-Krnlx/releases/download/v1.0/Ccminer_x86_krnlx.zip"


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Devices = $CCDevices2

#Algorithms:
#Xevan

$Commands = [PSCustomObject]@{
 'Xevan' = '-i 18'
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq $($Pools.(Get-Algo($_)).Coin))
     {
       [PSCustomObject]@{
       MinerName = "ccminer"
       Type = "NVIDIA2"
       Path = $Path
       Distro = $Distro
       Devices = $Devices
       Arguments = "-a $_ -o stratum+tcp://$($Pools.(Get-Algo($_)).Host):$($Pools.(Get-Algo($_)).Port) -b 0.0.0.0:4070 -u $($Pools.(Get-Algo($_)).User2) -p $($Pools.(Get-Algo($_)).Pass2) $($Commands.$_)"
       HashRates = [PSCustomObject]@{(Get-Algo($_)) = $Stats."$($Name)_$(Get-Algo($_))_HashRate".Live}
       Selected = [PSCustomObject]@{(Get-Algo($_)) = ""}
       Port = 4070
       API = "Ccminer"
       Wrap = $false
       URI = $Uri
       BUILD = $Build
      }
     }
   }