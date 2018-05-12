#!/bin/bash
#
StatsInterval=1 				                         #1 for Dynamic Benchmarking Of Devices, 1000 For Static (Benchmarks once, then doesn't do it again)
UserName=MaynardVII				                         #Username For Pools Which Require It
WorkerName=Rig1				                                 #Workername For Pools Which Require It
RigName=MMHash				                                 #Personal Nickname Of Your Mining Rig (for tracking purposes)
Currency=USD				                                 #Fiat Currency You Prefer
Passwordcurrency=RVN		                                         #Coin You Want To Exchange To For Pools Which Offer Mining Coin Exchange...See Your Mining Pool For More Information
CoinExchange=RVN							 #Excange Quote From CryptoExchange. Keep PasswordCurrency Symbol, unless coin symbol on exchange is different!
Interval=300				                                 #Seconds Miner Runs Before Switching (5 minutes is reccommended, 10+ for slower devices)
Delay=1					                                 #Delay Before Miner Switches (Leave alone- EXPERT/DEBUG MODE ONLY!)
Wallet=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H                                #Wallet Address- Should Be Address Of PasswordCurrency
Location=US				        	                 #Your Country
PoolName=zergpool		          	                         #Name of Pool You Wish To Mine In (See "Pools" dir To See Available Pools ex: zergpool,zpool,ahashpool)
Type=CPU,NVIDIA				        	                 #Devices You Are Mining With (NVIDIA,CPU,AMD) (CAREFULL COMBINING DEVICES!!
Algorithm=Yescrypt,Yescryptr16,Allium,Neoscrypt,Lyra2v2,HMQ1725,Keccak,Lyra2z,Keccakc,Xevan,X16r,Hsr,X17,Blake2s,Bitcore,X16s,Phi,Timetravel,Skunk,Tribus,Sib,Skein,Groestl,Nist5,c11 #Algos To Mine
Donate=5                                                                #Donation Time In Minutes You Wish Mine For Further App Development- Will Only Activate Once A Day
Proxy='""'                                                                #Proxy Address (If You Are Using Proxy)
#
#
#
#
#
#
#####ADVANCED OPTIONS (DO NOT USE UNLESS YOU KNOW WHAT YOU ARE DOING!)
#
#Type=CPU,NVIDIA1,NVIDIA2,NVIDIA3,NVIDIA4,NVIDIA5,NVIDIA6,NVIDIA7,NVIDIA8                         # Place # in front of above 'Type', and use this one instead.
#
#GPUDevices1='"0"'
#Wallet1=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency1=RVN
#
#GPUDevices2='"2"'
#Wallet2=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency2=RVN
#
#GPUDevices3='"6"'
#Wallet3=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency3=RVN
#
#GPUDevices4='"1,3"'
#Wallet4=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency4=RVN
#
#GPUDevices5='"4,5"'
#Wallet5=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency5=RVN
#
#GPUDevices6='"6,7"'
#Wallet6=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency6=RVN
#
#GPUDevices7='"8,9"'
#Wallet7=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency7=RVN
#
#GPUDevices8='"10"'
#Wallet8=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H
#PasswordCurrency8=RVN
#
#
#
#
#
########FLAG COMMANDS###### DO NOT TOUCH!#######
a=$StatsInterval
b=$UserName
c=$WorkerName
d=$RigName
e=($Currency)
f=($Passwordcurrency)
g=$Interval
h=$Delay
i=$Wallet
j=$Location
k=$PoolName
l=$Type
m=$Algorithm
n=$Donate
o=$Proxy
p=$CoinExchange
s=$GPUDevices1
u=$Wallet1
v=$PasswordCurrency1
x=$GPUDevices2
y=$Wallet2
z=$PasswordCurrency2
aa=$GPUDevices3
bb=$Wallet3
cc=$PasswordCurrency3
dd=$GPUDevices4
ee=$Wallet4
ff=$PasswordCurrency4
gg=$GPUDevices5
hh=$Wallet5
ii=$PasswordCurrency5
NN=$GPUDevices6
PP=$Wallet6
QQ=$PasswordCurrency6
RR=$GPUDevices7
TT=$Wallet7
UU=$PasswordCurrency7
VV=$GPUDevices8
XX=$Wallet8
YY=$PasswordCurrency8
#
#
#
#
#
#
#
####COMMANDS- SEE README ON HOW TO EDIT FOR ADVANCED SETTINGS! OTHERWISE, DO NOT TOUCH!
#
pwsh -command "&.\MM.Hash.ps1 -StatsInterval $a -Username $b -WorkerName $c -RigName $d -Currency $e -Passwordcurrency $f -Interval $g -Delay $h -Wallet $i -Location $j -Poolname $k -Type $l -Algorithm $m -Donate $n -Proxy $o -CoinExchange $p" #-GPUDevices1 $s -Wallet1 $u -PasswordCurrency1 $v -GPUDevices2 $x -Wallet2 $y -PasswordCurrency2 $z -GPUDevices3 $aa -Wallet3 $bb -PasswordCurrency3 $cc -GPUDevices4 $dd -Wallet4 $ee -PasswordCurrency4 $ff -GPUDevics5 $gg -Wallet5 $hh -PasswordCurrency5 $ii -GPUDevices6 $nn -Wallet6 $pp -PasswordCurrency6 $qq -GPUDevices7 $RR -Wallet7 $TT -PasswordCurrency7 $UU -GPUDevices8 $VV -Wallet8 $XX -PasswordCurrency8 $YY"
