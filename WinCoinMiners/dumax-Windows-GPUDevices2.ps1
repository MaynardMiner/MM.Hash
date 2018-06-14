$Path = '.\Bin\dumax-Windows-GPUDevices2\ccminer.exe'
$Uri = 'https://github.com/DumaxFr/ccminer/releases/download/dumax-0.9.0/ccminer-dumax-0.9.0-w64.zip'
$Build = "Windows"
$Distro = "Windows"

$Devices = $GPUDevices2

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#PHI
#PHI2
#PHI2

$Commands = [PSCustomObject]@{
    "LUX" = '' #LUX
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
      [PSCustomObject]@{
      MinerName = "ccminer"
      Type = "NVIDIA2"
      Path = $Path
      Distro = $Distro
      PName = "ccminer.exe"
      Devices = $Devices
      Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
      HashRates = [PSCustomObject]@{ $_ = $Stats."$($Name)_$($_)_HashRate".Live}
      API = "Ccminer"
      Port = 4070
      Wrap = $false
      URI = $Uri
      BUILD = $Build
     }
     }
    }

