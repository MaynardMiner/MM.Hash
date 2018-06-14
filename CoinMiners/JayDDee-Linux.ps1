$Path = "./Bin/JayDDee/0"
$Uri = "https://github.com/JayDDee/cpuminer-opt.git"
$Build =  "Linux-Clean"
$Distro = "Linux"

#Algorithms
#Yescrypt
#YescryptR16
#Lyra2z
#M7M

$Commands = [PSCustomObject]@{
    "ARG-yescrypt" = ''
    "BSTY" = ''
    "UIS" = ''
    "XMY" = ''
    "CRP" = ''
    "YTN" = ''
    "ALPS" = ''
    "CRS" = ''
    "GIN" = ''
    "IFX" = ''
    "PYRO" = ''
    "TLR" = ''
    "VTL" = ''
    "XMG" = '' #M7M
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "cpuminer"
	Type = "CPU"
        Path = $Path
	Distro = $Distro
    Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4069 -u $($Pools.$_.User1) -p $($Pools.$_.Pass1) $($Commands.$_)"
    HashRates = [PSCustomObject]@{ $_ = $Stats."$($Name)_$($_)_HashRate".Day}
    API = "Ccminer"
        Port = 4048
        Wrap = $false
        URI = $Uri
    BUILD = $Build
	Tracker = $($Pools.$_.Tracker)
      }
	}
     }
