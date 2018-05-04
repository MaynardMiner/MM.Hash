#!/bin/bash
#
StatsInterval=1 				                          #1 for Dynamic Benchmarking Of Devices, 1000 For Static (Benchmarks once, then doesn't do it again)
UserName=MaynardVII				                          #Username For Pools Which Require It
WorkerName=Rig1				                          #Workername For Pools Which Require It
RigName=MMHash				                          #Personal Nickname Of Your Mining Rig (for tracking purposes)
Currency=USD				                                  #Fiat Currency You Prefer
Passwordcurrency=BTC			                 #Coin You Want To Exchange To For Pools Which Offer Mining Coin Exchange...See Your Mining Pool For More Information
Interval=300				                                  #Seconds Miner Runs Before Switching (5 minutes is reccommended, 10+ for slower devices)
Delay=2					                          #Delay Before Miner Switches (Leave alone- EXPERT/DEBUG MODE ONLY!)
Wallet=1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i	                          #Your Wallet Address- Should Be Address Of PasswordCurrency
Location=US				        	                  #Your Country
PoolName=zergpool			       	                          #Name of Pool You Wish To Mine In (See "Pools" dir To See Available Pools ex: zergpool,zpool,ahashpool)
Type=NVIDIA,CPU				        	                  #Devices You Are Mining With (NVIDIA,CPU,AMD)
SelectedAlgo=yescrypt,yescryptr16,qubit,quark,keccak,lyra2z,keccakc,xevan,x16r,hsr,x17,blake2s,bitcore,x16s,phi,timetravel,skunk,tribus,sib,skein,groestl,nist5,myr-gr  #Algos To Mine
Donate=5					                          #Donation Time In Minutes You Wish Mine For Further App Development- Will Only Activate Once A Day
Proxy='""'						                  #Proxy Address (If You Are Using Proxy)
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
m=functioncommitalgo
n=$Donate
o=$Proxy
p=$SelectedAlgo
#
pwsh -command "&.\MM.Hash.ps1 -StatsInterval $a -Username $b -WorkerName $c -RigName $d -Currency $e -Passwordcurrency $f -Interval $g -Delay $h -Wallet $i -Location $j -Poolname $k -Type $l -Algorithm $m -Donate $n -Proxy $o -SelectedAlgo $p"
