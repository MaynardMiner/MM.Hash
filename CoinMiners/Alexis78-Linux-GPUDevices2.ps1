$Path = '.\Bin\alexis78\2'
$Uri = 'https://github.com/alexis78/ccminer.git'
$Build = "Linux"
$Distro = "Linux"

$Devices=$GPUDevices2

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

#Algorithms
#Skein
#X11
#Blake2s
#Sib 
#Quark
#C11
#Nist5
#Hsr

$Commands = [PSCustomObject]@{
"AGNI" = '-i 25' #Nist5
"BWK" = '-i 25' #Nist5
"CXT" = '-i 25' #Nist5
"RGC" = '-i 25' #Nist5
"HSR" = '' #Hsr
"AXS" = '-i 20' #C11
"BHD" = '-i 20' #C11
"CHC" = '-i 20' #C11
"DXC" = '-i 20' #C11
"FLAX" = '-i 20' #C11
"IMC" = '-i 20' #C11
"ITZ" = '-i 20' #C11
"JLG" = '-i 20' #C11
"KGX" = '-i 20' #C11
"RCO" = '-i 20' #C11
"SPD" = '-i 20' #C11
"BTQ" = '-i 20' #Quark
"LOBS" = '' #Quark
"QRK" = '' #Quark
"XMX" = '' #Quark
"SIB" = '-i 21' #Sib
"NEVA" = '' #Blake2s
"TAJ" = '' #Blake2s
"XSH-blake2s" = '' #Blake2s
"XVG-blake2s" = '' #Blake2s
"PAC" = '' #X11
"ADV" = '' #X11
"ADZ" = '' #X11
"ARC" = '' #X11
"BOLI" = '' #X11
"CANN" = '' #X11
"CRM" = '' #X11
"DGC" = '' #X11
"EQT" = '' #X11
"ERY" = '' #X11
"FIDGT" = '' #X11
"HBC" = '' #X11
"HPC" = '' #X11
"IN" = '' #X11
"INFX" = '' #X11
"KURT" = '' #X11
"MAG" = '' #X11
"MAR" = '' #X11
"MARX" = '' #X11
"MUE" = '' #X11
"NERO" = '' #X11
"OLIT" = '' #X11
"OMEGA" = '' #X11
"PCOIN" = '' #X11
"PNX" = '' #X11
"POLIS" = '' #X11
"PURA" = '' #X11
"PXI" = '' #X11
"SAND" = '' #X11
"SLASH" = '' #X11
"SMC" = '' #X11
"START" = '' #X11
"UIS-x11" = '' #X11
"ULTRA" = '' #X11
"WSX" = '' #X11
"XMCC" = '' #X11
"ZSE" = '' #X11
"ARGO" = '-i 28' #Skein
"AUR-skein" = '-i 28' #Skein
"BTPL" = '-i 28' #Skein
"CURV" = '-i 28' #Skein
"DGB-skein" = '-i 28' #Skein
"FRM" = '-i 28' #Skein
"LIZ" = '-i 28' #Skein
"PRTX" = '-i 28' #Skein
"SKC" = '-i 28' #Skein
"TIMEC" = '-i 28' #Skein
"UIS-skein" = '-i 28' #Skein
"ULT" = '-i 28' #Skein
"XMY-skein" = '-i 28' #Skein
}

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    if($Algorithm -eq "$($Pools.$_.Algorithm)")
     {
    [PSCustomObject]@{
        MinerName = "ccminer"
	Type = "NVIDIA2"
        Path = $Path
	Distro = $Distro
	Devices = $Devices
  	Arguments = "-a $($Pools.$_.Algorithm) -o stratum+tcp://$($Pools.$_.Host):$($Pools.$_.Port) -b 0.0.0.0:4070 -u $($Pools.$_.User2) -p $($Pools.$_.Pass2) $($Commands.$_)"
        HashRates = [PSCustomObject]@{$_ = $Stats."$($Name)_$($_)_HashRate".Live}
        API = "Ccminer"
        Port = 4070
        Wrap = $false
        URI = $Uri
	   BUILD = $Build	
        Tracker = $($Pools.$_.Tracker)
         }

     }
  }
