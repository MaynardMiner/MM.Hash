$Path = '.\Bin\Tpruvot-Allium-Windows-CCDevices2-Coin\ccminer-x64.exe'
$Uri = 'https://t.co/lFAnmZ4q1Z'
$Build = "Zip"
$Distro = "Windows"

if($CCDevices2 -ne ''){$Devices = $CCDevices2}
if($GPUDevices2 -ne ''){$Devices = $GPUDevices2}
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Allium
#XMR

$Commands = [PSCustomObject]@{
    "GRLC" = '' #Allium
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
     [PSCustomObject]@{
      MinerName = "ccminer"
	    Type = "NVIDIA2"
        Path = $Path
	    Distro = $Distro
	    PName = "ccminer-x64.exe"
	    Devices = $Devices
        Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
        API = "Ccminer"
        Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
        Port = 4070
        Wrap = $false
        URI = $Uri
	    BUILD = $Build
      }
     }
    }
