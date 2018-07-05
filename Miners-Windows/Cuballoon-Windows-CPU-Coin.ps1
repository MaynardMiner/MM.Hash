$Path = ".\Bin\Cuballoon-Windows-CPU-Coin\cuballoon.exe"
$Uri = "https://github.com/Belgarion/cuballoon/files/2143221/CuBalloon.1.0.2.Windows.zip"
$Build = "Zip"
$Distro = "Linux-Cu"

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Balloon

$Commands = [PSCustomObject]@{
"DEFT" = ''
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
  if($Algorithm -eq $($Pools.$_.Algorithm))
  {
 [PSCustomObject]@{
     MinerName = "ccminer"
     Type = "CPU"
     Path = $Path
     Distro = $Distro
     Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4048 -u $($Pools.$_.CPUser) -p $($Pools.$_.CPUPass) $($Commands.$_)"
     HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
     API = "cuballoon"
     Selected = [PSCustomObject]@{$($Pools.$_.Algorithm) = ""}
     Port = 4048
     Wrap = $false
     URI = $Uri
     BUILD = $Build
     Tracker = $($Pools.$_.Tracker)
    }
  }
}
