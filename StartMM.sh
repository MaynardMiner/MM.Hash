#!/bin/bash
#
StatsInterval=1 				                         #1 for Dynamic Benchmarking Of Devices, 1000 For Static (Benchmarks once, then doesn't do it again)
UserName=MaynardVII				                         #Username For Pools Which Require It
WorkerName=Rig1				                                 #Workername For Pools Which Require It
RigName=MMHash				                                 #Personal Nickname Of Your Mining Rig (for tracking purposes)
Currency=USD				                                  #Fiat Currency You Prefer
Passwordcurrency=RVN		                                         #Coin You Want To Exchange To For Pools Which Offer Mining Coin Exchange...See Your Mining Pool For More Information
CoinExchange=RVN							  #Excange Quote From CryptoExchange. Keep PasswordCurrency Symbol, unless coin symbol on exchange is different!
Interval=300				                                  #Seconds Miner Runs Before Switching (5 minutes is reccommended, 10+ for slower devices)
Delay=2					                                  #Delay Before Miner Switches (Leave alone- EXPERT/DEBUG MODE ONLY!)
Wallet=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H                                  #Wallet Address- Should Be Address Of PasswordCurrency
Location=US				        	                  #Your Country
PoolName=zergpool		          	                          #Name of Pool You Wish To Mine In (See "Pools" dir To See Available Pools ex: zergpool,zpool,ahashpool)
Type=NVIDIA				        	                  #Devices You Are Mining With (NVIDIA,CPU,AMD) (CAREFULL COMBINING DEVICES!!
Algorithm=Yescrypt,Yescryptr16,Neoscrypt,HMQ1725,Keccak,Lyra2z,Keccakc,Xevan,X16r,Hsr,X17,Blake2s,Bitcore,X16s,Phi,Timetravel,Skunk,Tribus,Sib,Skein,Groestl,Nist5,MyriadGroestl,lyra2RE2,c11 #Algos To Mine
Donate=5					                          #Donation Time In Minutes You Wish Mine For Further App Development- Will Only Activate Once A Day
Proxy='""'						                  #Proxy Address (If You Are Using Proxy)
#
#
#
#
#
#
#####Leave The Below Alone
#
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
p=$SelectedAlgo
q=$CoinExchange
#
pwsh -command "&.\MM.Hash.ps1 -StatsInterval $a -Username $b -WorkerName $c -RigName $d -Currency $e -Passwordcurrency $f -Interval $g -Delay $h -Wallet $i -Location $j -Poolname $k -Type $l -Algorithm $m -Donate $n -Proxy $o -CoinExchange $q"
