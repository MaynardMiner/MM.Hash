$Path = '.\Bin\MSFTserver\4'
$Uri = 'https://github.com/MSFTserver/ccminer.git'
$Build = "Linux-Clean"
$Distro = "Linux"

$Devices = $CCDevices2

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms:
#Lyra2z
#Bitcore
#Hmq1725
#Timetravel

$Commands = [PSCustomObject]@{
    "ALPS" = '' #Lyra2z
    "CRS" = '' #Lyra2z
    "GIN" = '' #Lyra2z
    "IFX" = '' #Lyra2z
    "MANO" = '' #Lyra2z
    "PYRO" = '' #Lyra2z
    "TLR" = '' #Lyra2z
    "VTL" = '' #Lyra2z
    "BTX" = '' #Bitcore
    "BRAZ" = '' #Hmq1725
    "ERA" = '' #Hmq1725
    "ESP" = '' #Hmq1725
    "PLUS" = '' #Hmq1725
    "VEGI" = '' #Hmq1725
    "MAC" = '' #Timetravel
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "ccminer"
        Type = "NVIDIA2"
        Path = $Path
	Devices = $Devices
	Distro = $Distro
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
                     
