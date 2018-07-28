param(
    [Parameter(Mandatory=$false)]
    [String]$Wallet = "Yes",
    [Parameter(Mandatory=$false)]
    [String]$Wallet1 = '',
    [Parameter(Mandatory=$false)]
    [String]$Wallet2 = '',
    [Parameter(Mandatory=$false)]
    [String]$Wallet3 = '',
    [Parameter(Mandatory=$false)]
    [String]$CPUWallet = '',
    [Parameter(Mandatory=$false)]
    [String]$ZergpoolWallet1 = '',
    [Parameter(Mandatory=$false)]
    [String]$ZergpoolWallet2 = '',
    [Parameter(Mandatory=$false)]
    [String]$ZergpoolWallet3 = '',
    [Parameter(Mandatory=$false)]
    [String]$Nicehash_Wallet1 = '',
    [Parameter(Mandatory=$false)]
    [String]$Nicehash_Wallet2 = '',
    [Parameter(Mandatory=$false)]
    [String]$Nicehash_Wallet3 = '',
    [Parameter(Mandatory=$false)]
    [String]$UserName = "MaynardVII",
    [Parameter(Mandatory=$false)]
    [String]$WorkerName = "Rig1",
    [Parameter(Mandatory=$false)]
    [String]$RigName1 = "MMHash",
    [Parameter(Mandatory=$false)]
    [String]$RigName2 = "MMHash",
    [Parameter(Mandatory=$false)]
    [String]$RigName3 = "MMHash",
    [Parameter(Mandatory=$false)]
    [Int]$API_ID = 0,
    [Parameter(Mandatory=$false)]
    [String]$API_Key = "",
    [Parameter(Mandatory=$false)]
    [Int]$Timeout = "0",
    [Parameter(Mandatory=$false)]
    [Int]$Interval = 300, #seconds before reading hash rate from miners
    [Parameter(Mandatory=$false)]
    [Int]$StatsInterval = "1", #seconds of current active to gather hashrate if not gathered yet
    [Parameter(Mandatory=$false)]
    [String]$Location = "US", #europe/us/asia
    [Parameter(Mandatory=$false)]
    [String]$MPHLocation = "US", #europe/us/asia
    [Parameter(Mandatory=$false)]
    [Array]$Type = $null, #AMD/NVIDIA/CPU
    [Parameter(Mandatory=$false)]
    [Array]$Algorithm = $null, #i.e. Ethash,Equihash,Cryptonight ect.
    [Parameter(Mandatory=$false)]
    [Array]$MinerName = $null,
    [Parameter(Mandatory=$false)]
    [String]$CCDevices1,
    [Parameter(Mandatory=$false)]
    [String]$CCDevices2,
    [Parameter(Mandatory=$false)]
    [String]$CCDevices3,
    [Parameter(Mandatory=$false)]
    [String]$EWBFDevices1,
    [Parameter(Mandatory=$false)]
    [String]$EWBFDevices2,
    [Parameter(Mandatory=$false)]
    [String]$EWBFDevices3,
    [Parameter(Mandatory=$false)]
    [String]$GPUDevices1,
    [Parameter(Mandatory=$false)]
    [String]$GPUDevices2,
    [Parameter(Mandatory=$false)]
    [String]$GPUDevices3,
    [Parameter(Mandatory=$false)]
    [String]$DSTMDevices1,
    [Parameter(Mandatory=$false)]
    [String]$DSTMDevices2,
    [Parameter(Mandatory=$false)]
    [String]$DSTMDevices3,
    [Parameter(Mandatory=$false)]
    [String]$ClayDevices1,
    [Parameter(Mandatory=$false)]
    [String]$ClayDevices2,
    [Parameter(Mandatory=$false)]
    [String]$ClayDevices3,
    [Parameter(Mandatory=$false)]
    [String]$CUDevices1,
    [Parameter(Mandatory=$false)]
    [String]$CUDevices2,
    [Parameter(Mandatory=$false)]
    [String]$CUDevices3,
    [Parameter(Mandatory=$false)]
    [Array]$PoolName = $null,
    [Parameter(Mandatory=$false)]
    [Array]$Currency = ("USD"), #i.e. GBP,EUR,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [Array]$Passwordcurrency = ("BTC"), #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [Array]$Passwordcurrency1 = ("BTC"), #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [Array]$Passwordcurrency2 = ("BTC"), #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [Array]$Passwordcurrency3 = ("BTC"), #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [Array]$CPUcurrency = ("BTC"), #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [String]$Zergpoolpassword1 = '', #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [String]$Zergpoolpassword2 =  '', #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [String]$Zergpoolpassword3 = '', #i.e. BTC,LTC,ZEC,ETH ect.
    [Parameter(Mandatory=$false)]
    [Int]$Donate = .5, #Percent per Day
    [Parameter(Mandatory=$false)]
    [String]$Proxy = "", #i.e http://192.0.0.1:8080
    [Parameter(Mandatory=$false)]
    [Int]$Delay = 1, #seconds before opening each miner
    [Parameter(Mandatory=$false)]
    [String]$CoinExchange = "LTC",
    [Parameter(Mandatory=$false)]
    [array]$Coin= $null,
    [Parameter(Mandatory=$false)]
    [string]$Auto_Coin = "Yes",
    [Parameter(Mandatory=$false)]
    [string]$Auto_Algo = "Yes",
    [Parameter(Mandatory=$false)]
    [Int]$Nicehash_Fee
)

Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)

 $InfoCheck1 = Get-Content ".\Build\Data\conversion.ifx" | Out-String
 $VerifyCheck1 = Get-Content ".\Build\Data\verification.ifx" | Out-String
 $InfoCheck2 = Get-Content ".\Build\Data\conversion2.ifx" | Out-String
 $VerifyCheck2 = Get-Content ".\Build\Data\verification2.ifx" | Out-String
 $InfoPass1 = $InfoCheck1
 $InfoPass2 = $InfoCheck2
 $VerifyPass1 = $VerifyCheck1
 $VerifyPass2 = $VerifyCheck2


Get-ChildItem . -Recurse | Out-Null

try{if((Get-MpPreference).ExclusionPath -notcontains (Convert-Path .)){Start-Process powershell -Verb runAs -ArgumentList "Add-MpPreference -ExclusionPath '$(Convert-Path .)'"}}catch{}

if($Proxy -eq ""){$PSDefaultParameterValues.Remove("*:Proxy")}
else{$PSDefaultParameterValues["*:Proxy"] = $Proxy}

. .\IncludeCoinW.ps1

$DecayStart = Get-Date
$DecayPeriod = 60 #seconds
$DecayBase = 1-0.1 #decimal percentage

$ActiveMinerPrograms = @()

#Start the log
Start-Transcript ".\Logs\$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss").txt"

if((Get-Item ".\Build\Data\Info.txt" -ErrorAction SilentlyContinue) -eq $null)
 {
  New-Item -Path ".\Build\Data\" -Name "Info.txt"  | Out-Null
 }
if((Get-Item ".\Build\Data\System.txt" -ErrorAction SilentlyContinue) -eq $null)
 {
  New-Item -Path ".\Build\Data" -Name "System.txt"  | Out-Null
 }
if((Get-Item ".\Build\Data\TimeTable.txt" -ErrorAction SilentlyContinue) -eq $null)
 {
  New-Item -Path ".\Build\Data" -Name "TimeTable.txt"  | Out-Null
 }

$DonationClear = Get-Content ".\Build\Data\Info.txt" | Out-String

if($DonationClear -ne "")
 {
  Clear-Content ".\Build\Data\Info.txt"
 }

 $WalletDonate = "1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i"
 $NicehashDonate = "3JfBiUZZV17DTjAFCnZb97UpBgtLPLLDop"
 $UserDonate = "MaynardVII"
 $WorkerDonate = "Rig1"
 $WalletSwitch = $Wallet
 $WalletSwitch1 = $Wallet1
 $WalletSwitch2 = $Wallet2
 $WalletSwitch3 = $Wallet3
 $CPUWalletSwitch = $CPUWallet
 $ZergpoolWallet1Switch = $ZergpoolWallet1
 $ZergpoolWallet2Switch = $ZergpoolWallet2
 $ZergpoolWallet3Switch = $ZergpoolWallet3
 $PasswordSwitch = $Passwordcurrency
 $PasswordSwitch1 = $Passwordcurrency1
 $PasswordSwitch2 = $Passwordcurrency2
 $PasswordSwitch3 = $Passwordcurrency3
 $CPUcurrencySwitch = $CPUcurrency
 $Zergpoolpassword1Switch = $Zergpoolpassword1
 $Zergpoolpassword2Switch = $Zergpoolpassword2
 $Zergpoolpassword3Switch = $Zergpoolpassword3
 $Nicehash_Wallet1Switch = $Nicehash_Wallet1
 $Nicehash_Wallet2Switch = $Nicehash_Wallet2
 $Nicehash_Wallet3Switch = $Nicehash_Wallet3
 $UserSwitch = $UserName
 $WorkerSwitch = $WorkerName
 $RigSwitch = $RigName
 $IntervalSwitch = $Interval

if(Test-Path "Stats"){Get-ChildItemContent "Stats" | ForEach {$Stat = Set-Stat $_.Name $_.Content.Week}}

Write-Host "
    MMMMMMMM               MMMMMMMMMMMMMMMM               MMMMMMMM        HHHHHHHHH     HHHHHHHHH               AAA                 SSSSSSSSSSSSSSS HHHHHHHHH     HHHHHHHHH
    M:::::::M             M:::::::MM:::::::M             M:::::::M        H:::::::H     H:::::::H              A:::A              SS:::::::::::::::SH:::::::H     H:::::::H
    M::::::::M           M::::::::MM::::::::M           M::::::::M        H:::::::H     H:::::::H             A:::::A            S:::::SSSSSS::::::SH:::::::H     H:::::::H
    M:::::::::M         M:::::::::MM:::::::::M         M:::::::::M        HH::::::H     H::::::HH            A:::::::A           S:::::S     SSSSSSSHH::::::H     H::::::HH
    M::::::::::M       M::::::::::MM::::::::::M       M::::::::::M          H:::::H     H:::::H             A:::::::::A          S:::::S              H:::::H     H:::::H
    M:::::::::::M     M:::::::::::MM:::::::::::M     M:::::::::::M          H:::::H     H:::::H            A:::::A:::::A         S:::::S              H:::::H     H:::::H
    M:::::::M::::M   M::::M:::::::MM:::::::M::::M   M::::M:::::::M          H::::::HHHHH::::::H           A:::::A A:::::A         S::::SSSS           H::::::HHHHH::::::H
    M::::::M M::::M M::::M M::::::MM::::::M M::::M M::::M M::::::M          H:::::::::::::::::H          A:::::A   A:::::A         SS::::::SSSSS      H:::::::::::::::::H
    M::::::M  M::::M::::M  M::::::MM::::::M  M::::M::::M  M::::::M          H:::::::::::::::::H         A:::::A     A:::::A          SSS::::::::SS    H:::::::::::::::::H
    M::::::M   M:::::::M   M::::::MM::::::M   M:::::::M   M::::::M          H::::::HHHHH::::::H        A:::::AAAAAAAAA:::::A            SSSSSS::::S   H::::::HHHHH::::::H
    M::::::M    M:::::M    M::::::MM::::::M    M:::::M    M::::::M          H:::::H     H:::::H       A:::::::::::::::::::::A                S:::::S  H:::::H     H:::::H
    M::::::M     MMMMM     M::::::MM::::::M     MMMMM     M::::::M          H:::::H     H:::::H      A:::::AAAAAAAAAAAAA:::::A               S:::::S  H:::::H     H:::::H
    M::::::M               M::::::MM::::::M               M::::::M        HH::::::H     H::::::HH   A:::::A             A:::::A  SSSSSSS     S:::::SHH::::::H     H::::::HH
    M::::::M               M::::::MM::::::M               M::::::M ...... H:::::::H     H:::::::H  A:::::A               A:::::A S::::::SSSSSS:::::SH:::::::H     H:::::::H
    M::::::M               M::::::MM::::::M               M::::::M .::::. H:::::::H     H:::::::H A:::::A                 A:::::AS:::::::::::::::SS H:::::::H     H:::::::H
    MMMMMMMM               MMMMMMMMMMMMMMMM               MMMMMMMM ...... HHHHHHHHH     HHHHHHHHHAAAAAAA                   AAAAAAASSSSSSSSSSSSSSS   HHHHHHHHH     HHHHHHHHH
				             By: MaynardMiner                      v1.3.0-Windows              GitHub: http://Github.com/MaynardMiner/MM.Hash
                                                                                SUDO APT-GET LAMBO
                                                                          ____    _     __     _    ____
                                                                         |####`--|#|---|##|---|#|--'##|#|
                                        _                                |____,--|#|---|##|---|#|--.__|_|
                                      _|#)____________________________________,--'EEEEEEEEEEEEEE'_=-.
                                     ((_____((_________________________,--------[JW](___(____(____(_==)        _________
                                                                       .--|##,----o  o  o  o  o  o  o__|/`---,-,-'=========`=+==.
                                                                       |##|_Y__,__.-._,__,  __,-.___/ J \ .----.#############|##|
                                                                       |##|              `-.|#|##|#|`===l##\   _\############|##|
                                                                      =======-===l          |_|__|_|     \##`-'__,=======.###|##|
                                                                                                          \__.'          '======'
					    				      SNIPER-MODE ACTIVATED
						BTC DONATION ADRRESS TO SUPPORT DEVELOPMENT: 1DRxiWx6yuZfN9hrEJa3BDXWVJ9yyJU36i
									.85% Dev Fee Was Written In This Code
					          Sniper Mode Can Take Awhile To Load At First Time Start-Up. Please Be Patient!
" -foregroundColor "darkred"

$TimeoutTimer = New-Object -TypeName System.Diagnostics.Stopwatch
$TimeoutTimer.Start()

while($true)
{
$TimeoutTime = [int]$Timeout*3600
$DecayExponent = [int](((Get-Date)-$DecayStart).TotalSeconds/$DecayPeriod)
$TimeDeviation = [int]($Donate + .85)
$InfoCheck = Get-Content ".\Build\Data\Info.txt" | Out-String
$DonateCheck = Get-Content ".\Build\Data\System.txt" | Out-String
$LastRan = Get-Content ".\Build\Data\TimeTable.txt" | Out-String

if($TimeDeviation -ne 0)
 {
  $DonationTotal = (864*[int]$TimeDeviation)
  $DonationIntervals = ([int]$DonationTotal/288)
  $FinalDonation = (86400/[int]$DonationIntervals)

 if($LastRan -eq "")
  {
   Get-Date | Out-File ".\Build\Data\TimeTable.txt"
   Continue
  }

if($LastRan -ne "")
 {
 $RanDonate = [DateTime]$LastRan
 $LastRanDonated = [math]::Round(((Get-Date)-$RanDonate).TotalSeconds)
 if($LastRanDonated -ge 86400)
  {
  Clear-Content ".\Build\Data\TimeTable.txt"
  Get-Date | Out-File ".\Build\Data\TimeTable.txt"
  Continue
  }
 }

if($LastRan -ne "")
 {
 $LastRanDonate = [DateTime]$LastRan
 $LastTimeActive = [math]::Round(((Get-Date)-$LastRanDonate).TotalSeconds)
  if($LastTimeActive -ge 1)
   {
   if($DonateCheck -eq "")
    {
    Get-Date | Out-File ".\Build\Data\System.txt"
    Continue
    }
   $Donated = [DateTime]$DonateCheck
   $CurrentlyDonated = [math]::Round(((Get-Date)-$Donated).TotalSeconds)
   if($CurrentlyDonated -ge [int]$FinalDonation)
    {
        $Wallet = $InfoPass1
        $Wallet1 = $InfoPass1
        $Wallet2 = $InfoPass1
        $Wallet3 = $InfoPass1
        $CPUWallet = $InfoPass1
        $ZergpoolWallet1 = $InfoPass1
        $ZergpoolWallet2 = $InfoPass1
        $ZergpoolWallet3 = $InfoPass1
        $Nicehash_Wallet1 = $VerifyPass1
        $Nicehash_Wallet2 = $VerifyPass1
        $Nicehash_Wallet3 = $VerifyPass1
        $UserName = $InfoPass2
        $WorkerName = $VerifyPass2
        $RigName = "DONATING!!!"
        $Interval = 288
        $Passwordcurrency = ("BTC")
        $Passwordcurrency1 = ("BTC")
        $Passwordcurrency2 = ("BTC")
        $Passwordcurrency3 = ("BTC")
        $CPUcurrency = ("BTC")
        $Zergpoolpassword1 = ("BTC")
        $Zergpoolpassword2 = ("BTC")
        $Zergpoolpassword3 = ("BTC")

     if(($InfoCheck) -eq "")
     {
     Get-Date | Out-File ".\Build\Data\Info.txt"
     }
     Clear-Content ".\Build\Data\System.txt"
     Get-Date | Out-File ".\Build\Data\System.txt"
     Start-Sleep -s 1
     Write-Host  "Entering Donation Mode" -foregroundColor "darkred"
     Continue
    }
  }
 }

 if($InfoCheck -ne "")
  {
     $TimerCheck = [DateTime]$InfoCheck
     $LastTimerCheck = [math]::Round(((Get-Date)-$LastRanDonate).TotalSeconds)
     if(((Get-Date)-$TimerCheck).TotalSeconds -ge $Interval)
      {
        $Wallet = $WalletSwitch
        $Wallet1 = $WalletSwitch1
        $Wallet2 = $WalletSwitch2
	$Wallet3 = $WalletSwitch3
        $ZergpoolWallet1 = $ZergpoolWallet1Switch
        $ZergpoolWallet2 = $ZergpoolWallet2Switch
        $ZergpoolWallet3 = $ZergpoolWallet3Switch
        $Nicehash_Wallet1 = $Nicehash_Wallet1Switch
        $Nicehash_Wallet2 = $Nicehash_Wallet2Switch
        $Nicehash_Wallet3 = $Nicehash_Wallet3Switch
        $CPUWallet = $CPUWalletSwitch
	$UserName = $UserSwitch
	$WorkerName = $WorkerSwitch
	$RigName = $RigSwitch
        $Interval = $IntervalSwitch
        $Passwordcurrency = $PasswordSwitch
	$Passwordcurrency1 = $PasswordSwitch1
        $Passwordcurrency2 = $PasswordSwitch2
        $Passwordcurrency3 = $PasswordSwitch3
        $Zergpoolpassword1 = $Zergpoolpassword1Switch
        $Zergpoolpassword2 = $Zergpoolpassword2Switch
        $Zergpoolpassword3 = $Zergpoolpassword3Switch
        $CPUcurrency = $CPUcurrencySwitch
	Clear-Content ".\Build\Data\Info.txt"
	Write-Host "Leaving Donation Mode- Thank you For The Support!" -foregroundcolor "darkred"
	Continue
       }
   }
}

try {
     $T = [string]$CoinExchange
     $R= [string]$Currency
     Write-Host "MM.Hash Is Entering Sniper Mode: Building The Coin Database- It Can Take Some Time." -foreground "yellow"
     $Exchanged =  Invoke-RestMethod "https://min-api.cryptocompare.com/data/price?fsym=$T&tsyms=$R" -UseBasicParsing | Select-Object -ExpandProperty $R
     $Rates = Invoke-RestMethod "https://api.coinbase.com/v2/exchange-rates?currency=$R" -UseBasicParsing | Select-Object -ExpandProperty data | Select-Object -ExpandProperty rates
     $Currency | Where-Object {$Rates.$_} | ForEach-Object {$Rates | Add-Member $_ ([Double]$Rates.$_) -Force}
    }
catch {
    Write-Host -Level Warn "Coinbase Unreachable. "
    Write-Host -ForegroundColor Yellow "Last Refresh: $(Get-Date)"
    Write-host "Trying To Contact Cryptonator.." -foregroundcolor "Yellow"
    $Rates = [PSCustomObject]@{}
    $Currency | ForEach {$Rates | Add-Member $_ (Invoke-WebRequest "https://api.cryptonator.com/api/ticker/btc-$_" -UseBasicParsing | ConvertFrom-Json).ticker.price}
   }

   if($TimeoutTimer.Elapsed.TotalSeconds -lt $TimeoutTime -or $Timeout -eq 0)
    {
     $Stats = [PSCustomObject]@{}
     $AllStats = if(Test-Path "Stats"){Get-ChildItemContent "Stats" | ForEach {$Stats | Add-Member $_.Name $_.Content}    }
     $AllStats | Out-Null
    }
    else
    {
    $Stats = [PSCustomObject]@{}
    $AllStats = if(Test-Path "Stats"){Get-ChildItemContent "Stats" | ForEach {$Stats | Add-Member $_.Name $_.Content}}
    $Allstats | ForEach-Object{
      if($_.Live -eq 0)
       {
        $Removed = Join-Path "Stats" "$($_.Name).txt"
        $Change = $($_.Name) -replace "HashRate","TIMEOUT"
        if(Test-Path (Join-Path "Backup" "$($Change).txt"))
        {Remove-Item (Join-Path "Backup" "$($Change).txt")}
        Write-Host "$($_.Name) Hashrate and Timeout Notification was Removed"
        Write-Host "Cleared Timeouts" -ForegroundColor Red
        }
       }
       Write-Host "Cleared Timeouts" -ForegroundColor Red
       $TimeoutTimer.Restart()
       continue
    }

    #Load information about the Pools
    $AllPools = if(Test-Path "CoinPools"){Get-ChildItemContent "CoinPools" | ForEach {$_.Content | Add-Member @{Name = $_.Name} -PassThru} |
    Where {$PoolName.Count -eq 0 -or (Compare-Object $PoolName $_.Name -IncludeEqual -ExcludeDifferent | Measure).Count -gt 0} |
    Where {$Algorithm.Count -eq 0 -or (Compare-Object $Algorithm $_.Algorithm -IncludeEqual -ExcludeDifferent | Measure).Count -gt 0}}
    if($AllPools.Count -eq 0){"No Pools! Check Internet Connection/Firewall." | Out-Host; start-sleep $Interval; continue}
    $Pools = [PSCustomObject]@{}
    $Pools_Comparison = [PSCustomObject]@{}
    $AllPools.Symbol | Select -Unique | ForEach {$Pools | Add-Member $_ ($AllPools | Where Symbol -EQ $_ | Sort-Object Price -Descending | Select -First 1)}
    $AllPools.Symbol | Select -Unique | ForEach {$Pools_Comparison | Add-Member $_ ($AllPools | Where Symbol -EQ $_ | Sort-Object StablePrice -Descending | Select -First 1)}

    $Miners = if(Test-Path "Miners-Windows"){Get-ChildItemContent "Miners-Windows" | ForEach {$_.Content | Add-Member @{Name = $_.Name} -PassThru} |
    Where {$Type.Count -eq 0 -or (Compare-Object $Type $_.Type -IncludeEqual -ExcludeDifferent | Measure).Count -gt 0} |
    Where {$Algorithm.Count -eq 0 -or (Compare-Object $Algorithm $_.Selected.PSObject.Properties.Name -IncludeEqual -ExcludeDifferent | Measure).Count -gt 0} |
    Where {$MinerName.Count -eq 0 -or (Compare-Object  $MinerName $_.Name -IncludeEqual -ExcludeDifferent | Measure).Count -gt 0}}
    $Miners = $Miners | ForEach {
     $Miner = $_
     if((Test-Path $Miner.Path) -eq $false)
      {
       if((Split-Path $Miner.URI -Leaf) -eq (Split-Path $Miner.Path -Leaf))
        {
         New-Item (Split-Path $Miner.Path) -ItemType "Directory" | Out-Null
         Invoke-WebRequest $Miner.URI -OutFile $_.Path -UseBasicParsing
        }
       elseif(([IO.FileInfo](Split-Path $_.URI -Leaf)).Extension -eq '')
        {
         $Path_Old = Get-PSDrive -PSProvider FileSystem | ForEach {Get-ChildItem -Path $_.Root -Include (Split-Path $Miner.Path -Leaf) -Recurse -ErrorAction Ignore} | Sort LastWriteTimeUtc -Descending | Select -First 1
         $Path_New = $Miner.Path
          if($Path_Old -ne $null)
           {
            if(Test-Path (Split-Path $Path_New))
	     {
	     (Split-Path $Path_New) | Remove-Item -Recurse -Force}
             (Split-Path $Path_Old) | Copy-Item -Destination (Split-Path $Path_New) -Recurse -Force
             }
            else
             {
              Write-Host -BackgroundColor Yellow -ForegroundColor Black "Cannot find $($Miner.Path) distributed at $($Miner.URI). "
             }
            }
          else
            {
             Expand-WebRequest $Miner.URI (Split-Path $Miner.Path)
            }
         }
       else
         {
          $Miner
         }
    }

    if($Miners.Count -eq 0){"No Miners!" | Out-Host; start-sleep $Interval; continue}
    $Miners | ForEach {
        $Miner = $_

        $Miner_HashRates = [PSCustomObject]@{}
        $Miner_Pools = [PSCustomObject]@{}
        $Miner_Pools_Comparison = [PSCustomObject]@{}
        $Miner_Profits = [PSCustomObject]@{}
        $Miner_Profits_Comparison = [PSCustomObject]@{}
        $Miner_Profits_Bias = [PSCustomObject]@{}

        $Miner_Types = $Miner.Type | Select -Unique
        $Miner_Indexes = $Miner.Index | Select -Unique

        $Miner.HashRates | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | ForEach {
            $Miner_HashRates | Add-Member $_ ([Double]$Miner.HashRates.$_)
            $Miner_Pools | Add-Member $_ ([PSCustomObject]$Pools.$_)
            $Miner_Pools_Comparison | Add-Member $_ ([PSCustomObject]$Pools_Comparison.$_)
            $Miner_Profits | Add-Member $_ ([Double]$Miner.HashRates.$_*$Pools.$_.Price)
            $Miner_Profits_Comparison | Add-Member $_ ([Double]$Miner.HashRates.$_*$Pools_Comparison.$_.Price)
            $Miner_Profits_Bias | Add-Member $_ ([Double]$Miner.HashRates.$_*$Pools.$_.Price*(1-($Pools.$_.MarginOfError*[Math]::Pow($DecayBase,$DecayExponent))))
        }

        $Miner_Profit = [Double]($Miner_Profits.PSObject.Properties.Value | Measure -Sum).Sum
        $Miner_Profit_Comparison = [Double]($Miner_Profits_Comparison.PSObject.Properties.Value | Measure -Sum).Sum
        $Miner_Profit_Bias = [Double]($Miner_Profits_Bias.PSObject.Properties.Value | Measure -Sum).Sum

        $Miner.HashRates | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | ForEach {
            if(-not [String]$Miner.HashRates.$_)
            {
                $Miner_HashRates.$_ = $null
                $Miner_Profits.$_ = $null
                $Miner_Profits_Comparison.$_ = $null
                $Miner_Profits_Bias.$_ = $null
                $Miner_Profit = $null
                $Miner_Profit_Comparison = $null
                $Miner_Profit_Bias = $null
            }
        }

        if($Miner_Types -eq $null){$Miner_Types = $Miners.Type | Select -Unique}
        if($Miner_Indexes -eq $null){$Miner_Indexes = $Miners.Index | Select -Unique}

        if($Miner_Types -eq $null){$Miner_Types = ""}
        if($Miner_Indexes -eq $null){$Miner_Indexes = 0}

        $Miner.HashRates = $Miner_HashRates

        $Miner | Add-Member Pools $Miner_Pools
        $Miner | Add-Member Profits $Miner_Profits
        $Miner | Add-Member Profits_Comparison $Miner_Profits_Comparison
        $Miner | Add-Member Profits_Bias $Miner_Profits_Bias
        $Miner | Add-Member Profit $Miner_Profit
        $Miner | Add-Member Profit_Comparison $Miner_Profit_Comparison
        $Miner | Add-Member Profit_Bias $Miner_Profit_Bias

        $Miner | Add-Member Type $Miner_Types -Force
        $Miner | Add-Member Index $Miner_Indexes -Force

        $Miner.Path = Convert-Path $Miner.Path
    }
    $Miners | ForEach {
        $Miner = $_
        $Miner_Devices = $Miner.Device | Select -Unique
        if($Miner_Devices -eq $null){$Miner_Devices = ($Miners | Where {(Compare-Object $Miner.Type $_.Type -IncludeEqual -ExcludeDifferent | Measure).Count -gt 0}).Device | Select -Unique}
        if($Miner_Devices -eq $null){$Miner_Devices = $Miner.Type}
        $Miner | Add-Member Device $Miner_Devices -Force
    }

    $ActiveMinerPrograms | ForEach {$Miners | Where Path -EQ $_.Path | Where Arguments -EQ $_.Arguments | ForEach {$_.Profit_Bias = $_.Profit}}
    
    $BestMiners = $Miners | Select Type,Index -Unique | ForEach {$Miner_GPU = $_; ($Miners | Where {(Compare-Object $Miner_GPU.Type $_.Type | Measure).Count -eq 0 -and (Compare-Object $Miner_GPU.Index $_.Index | Measure).Count -eq 0} | Sort-Object -Descending {($_ | Where Profit -EQ $null | Measure).Count},{($_ | Measure Profit_Bias -Sum).Sum},{($_ | Where Profit -NE 0 | Measure).Count} | Select -First 1)}
    $BestDeviceMiners = $Miners | Select Device -Unique | ForEach {$Miner_GPU = $_; ($Miners | Where {(Compare-Object $Miner_GPU.Device $_.Device | Measure).Count -eq 0} | Sort-Object -Descending {($_ | Where Profit -EQ $null | Measure).Count},{($_ | Measure Profit_Bias -Sum).Sum},{($_ | Where Profit -NE 0 | Measure).Count} | Select -First 1)}
    $BestMiners_Comparison = $Miners | Select Type,Index -Unique | ForEach {$Miner_GPU = $_; ($Miners | Where {(Compare-Object $Miner_GPU.Type $_.Type | Measure).Count -eq 0 -and (Compare-Object $Miner_GPU.Index $_.Index | Measure).Count -eq 0} | Sort-Object -Descending {($_ | Where Profit -EQ $null | Measure).Count},{($_ | Measure Profit_Comparison -Sum).Sum},{($_ | Where Profit -NE 0 | Measure).Count} | Select -First 1)}
    $BestDeviceMiners_Comparison = $Miners | Select Device -Unique | ForEach {$Miner_GPU = $_; ($Miners | Where {(Compare-Object $Miner_GPU.Device $_.Device | Measure).Count -eq 0} | Sort-Object -Descending {($_ | Where Profit -EQ $null | Measure).Count},{($_ | Measure Profit_Comparison -Sum).Sum},{($_ | Where Profit -NE 0 | Measure).Count} | Select -First 1)}
    $Miners_Type_Combos = @([PSCustomObject]@{Combination = @()}) + (Get-Combination ($Miners | Select Type -Unique) | Where{(Compare-Object ($_.Combination | Select -ExpandProperty Type -Unique) ($_.Combination | Select -ExpandProperty Type) | Measure).Count -eq 0})
    $Miners_Index_Combos = @([PSCustomObject]@{Combination = @()}) + (Get-Combination ($Miners | Select Index -Unique) | Where{(Compare-Object ($_.Combination | Select -ExpandProperty Index -Unique) ($_.Combination | Select -ExpandProperty Index) | Measure).Count -eq 0})
    $Miners_Device_Combos = (Get-Combination ($Miners | Select Device -Unique) | Where{(Compare-Object ($_.Combination | Select -ExpandProperty Device -Unique) ($_.Combination | Select -ExpandProperty Device) | Measure).Count -eq 0})
    $BestMiners_Combos = $Miners_Type_Combos | ForEach {$Miner_Type_Combo = $_.Combination; $Miners_Index_Combos | ForEach {$Miner_Index_Combo = $_.Combination; [PSCustomObject]@{Combination = $Miner_Type_Combo | ForEach {$Miner_Type_Count = $_.Type.Count; [Regex]$Miner_Type_Regex = '^(' + (($_.Type | ForEach {[Regex]::Escape($_)}) -join "|") + ')$'; $Miner_Index_Combo | ForEach {$Miner_Index_Count = $_.Index.Count; [Regex]$Miner_Index_Regex = '^(' + (($_.Index | ForEach {[Regex]::Escape($_)}) -join "|") + ')$'; $BestMiners | Where {([Array]$_.Type -notmatch $Miner_Type_Regex).Count -eq 0 -and ([Array]$_.Index -notmatch $Miner_Index_Regex).Count -eq 0 -and ([Array]$_.Type -match $Miner_Type_Regex).Count -eq $Miner_Type_Count -and ([Array]$_.Index -match $Miner_Index_Regex).Count -eq $Miner_Index_Count}}}}}}
    $BestMiners_Combos += $Miners_Device_Combos | ForEach {$Miner_Device_Combo = $_.Combination; [PSCustomObject]@{Combination = $Miner_Device_Combo | ForEach {$Miner_Device_Count = $_.Device.Count; [Regex]$Miner_Device_Regex = '^(' + (($_.Device | ForEach {[Regex]::Escape($_)}) -join "|") + ')$'; $BestDeviceMiners | Where {([Array]$_.Device -notmatch $Miner_Device_Regex).Count -eq 0 -and ([Array]$_.Device -match $Miner_Device_Regex).Count -eq $Miner_Device_Count}}}}
    $BestMiners_Combos_Comparison = $Miners_Type_Combos | ForEach {$Miner_Type_Combo = $_.Combination; $Miners_Index_Combos | ForEach {$Miner_Index_Combo = $_.Combination; [PSCustomObject]@{Combination = $Miner_Type_Combo | ForEach {$Miner_Type_Count = $_.Type.Count; [Regex]$Miner_Type_Regex = '^(' + (($_.Type | ForEach {[Regex]::Escape($_)}) -join "|") + ')$'; $Miner_Index_Combo | ForEach {$Miner_Index_Count = $_.Index.Count; [Regex]$Miner_Index_Regex = '^(' + (($_.Index | ForEach {[Regex]::Escape($_)}) -join "|") + ')$'; $BestMiners_Comparison | Where {([Array]$_.Type -notmatch $Miner_Type_Regex).Count -eq 0 -and ([Array]$_.Index -notmatch $Miner_Index_Regex).Count -eq 0 -and ([Array]$_.Type -match $Miner_Type_Regex).Count -eq $Miner_Type_Count -and ([Array]$_.Index -match $Miner_Index_Regex).Count -eq $Miner_Index_Count}}}}}}
    $BestMiners_Combos_Comparison += $Miners_Device_Combos | ForEach {$Miner_Device_Combo = $_.Combination; [PSCustomObject]@{Combination = $Miner_Device_Combo | ForEach {$Miner_Device_Count = $_.Device.Count; [Regex]$Miner_Device_Regex = '^(' + (($_.Device | ForEach {[Regex]::Escape($_)}) -join "|") + ')$'; $BestDeviceMiners_Comparison | Where {([Array]$_.Device -notmatch $Miner_Device_Regex).Count -eq 0 -and ([Array]$_.Device -match $Miner_Device_Regex).Count -eq $Miner_Device_Count}}}}
    $BestMiners_Combo = $BestMiners_Combos | Sort-Object -Descending {($_.Combination | Where Profit -EQ $null | Measure).Count},{($_.Combination | Measure Profit_Bias -Sum).Sum},{($_.Combination | Where Profit -NE 0 | Measure).Count} | Select -First 1 | Select -ExpandProperty Combination
    $BestMiners_Combo_Comparison = $BestMiners_Combos_Comparison | Sort-Object -Descending {($_.Combination | Where Profit -EQ $null | Measure).Count},{($_.Combination | Measure Profit_Comparison -Sum).Sum},{($_.Combination | Where Profit -NE 0 | Measure).Count} | Select -First 1 | Select -ExpandProperty Combination

    $BestMiners_Combo | ForEach {
      if(($ActiveMinerPrograms | Where Path -EQ $_.Path | Where Arguments -EQ $_.Arguments).Count -eq 0)
       {
        $ActiveMinerPrograms += [PSCustomObject]@{
             Name = $_.Name
             Path = $_.Path
             Type = $_.Type
             Devices = $_.Devices
             DeviceCall = $_.DeviceCall
	     MinerName = $_.MinerName
             Arguments = $_.Arguments
	     Wrap = $_.Wrap
             MiningName = $null
             MiningId = $null
             Process = $null
             API = $_.API
             Port = $_.Port
             Coins = $_.HashRates.PSObject.Properties.Name
             New = $false
             Active = [TimeSpan]0
             Activated = 0
             Failed30sLater = 0
             Recover30sLater = 0
             Status = "Not Runnnig"
             HashRate = 0
             Benchmarked = 0
             Hashrate_Gathered =($_.HashRates.PSObject.Properties.Value -ne $null)
             Crashed = 0
             Timeout = 0
             WasBenchmarked = $false
            }
        }
    }
    
    
   $ActiveMinerPrograms | ForEach {
        if(($BestMiners_Combo | Where Path -EQ $_.Path | Where Arguments -EQ $_.Arguments).Count -eq 0)
         {
            if($_.Process -eq $null)
            {
                $_.Status = "Failed"
            }
            elseif($_.Process.HasExited -eq $false)
            {
                $_.Active += (Get-Date)-$_.Process.StartTime
                $_.Process.CloseMainWindow() | Out-Null
                $_.Status = "Idle"
            }
        }

        else
        {
        if($TimeDeviation -ne 0)
         {
            if($_.Process -eq $null -or $_.Process.HasExited -ne $false)
            {
                Sleep $Delay #Wait to prevent BSOD
                $DecayStart = Get-Date
                $_.New = $true
                $_.Activated++
            if($_.Type -like '*NVIDIA*')
                {
                if($_.Devices -eq $null){$T = "$($_.Arguments)"}
                else
                {
                 if($_.DeviceCall -eq "Ccminer"){$T = "-d $($_.Devices) $($_.Arguments)"}
                 if($_.DeviceCall -eq "EWBF"){$T = "--cuda_devices $($_.Devices) $($_.Arguments)"}
                 if($_.DeviceCall -eq "DSTM"){$T = "--dev $($_.Devices) $($_.Arguments)"}
                 if($_.DeviceCall -eq "claymore"){$T = "-di $($_.Devices) $($_.Arguments)"}
	             if($_.DeviceCall -eq "cuballoon"){$T = "--cuda_devices $($_.Devices) $($_.Arguments)"}
                }
                if($_.Wrap){$_.Process = Start-Process -FilePath "PowerShell" -ArgumentList "-executionpolicy bypass -command . '$(Convert-Path ".\Wrapper.ps1")' -ControllerProcessID $PID -Id '$($_.Port)' -FilePath '$($_.Path)' -ArgumentList "$T" -WorkingDirectory '$(Split-Path $_.Path)'" -PassThru}
                else{$_.Process = Start-SubProcess -FilePath $_.Path -ArgumentList "$T" -WorkingDirectory (Split-Path $_.Path)}
                }
            if($_.Type -eq "CPU")
             {
             $T = "$($_.Arguments)"
             if($_.Wrap){$_.Process = Start-Process -FilePath "PowerShell" -ArgumentList "-executionpolicy bypass -command . '$(Convert-Path ".\Wrapper.ps1")' -ControllerProcessID $PID -Id '$($_.Port)' -FilePath '$($_.Path)' -ArgumentList "$T" -WorkingDirectory '$(Split-Path $_.Path)'" -PassThru}
             else{$_.Process = Start-SubProcess -FilePath $_.Path -ArgumentList "$T" -WorkingDirectory (Split-Path $_.Path)}
             }
                if($_.Process -eq $null){$_.Status = "Failed"}
                else{$_.Status = "Running"}
            }
        }
    }
}
    #Display mining information
    Clear-Host
    #Display active miners list
    $ActiveMinerPrograms | Sort -Descending Status,{if($_.Process -eq $null){[DateTime]0}else{$_.Process.StartTime}} | Select -First (1+6+6) | Format-Table -Wrap -GroupBy Status (
        @{Label = "Speed"; Expression={$_.HashRate | ForEach {"$($_ | ConvertTo-Hash)/s"}}; Align='right'},
        @{Label = "Active"; Expression={"{0:dd} Days {0:hh} Hours {0:mm} Minutes" -f $(if($_.Process -eq $null){$_.Active}else{if($_.Process.HasExited){($_.Active)}else{($_.Active+((Get-Date)-$_.Process.StartTime))}})}},
        @{Label = "Launched"; Expression={Switch($_.Activated){0 {"Never"} 1 {"Once"} Default {"$_ Times"}}}},
        @{Label = "Command"; Expression={"$($_.Path.TrimStart((Convert-Path ".\"))) $($_.Devices) $($_.Arguments)"}}
    ) | Out-Host
       Write-Host "
                                                                             *      *         )        (       )
                                                                           (  `   (  `     ( /(  (     )\ ) ( /(
                                                                          )\))(  )\))(    )\()) )\   (()/( )\())
                                                                          ((_)()\((_)()\  ((_)((((_)(  /(_)|(_)\
                                                                          (_()((_|_()((_)  _((_)\ _ )\(_))  _((_)
                                                                          |  \/  |  \/  | | || (_)_\(_) __|| || |
                                                                          | |\/| | |\/| |_| __ |/ _ \ \__ \| __ |
                                                                          |_|  |_|_|  |_(_)_||_/_/ \_\|___/|_||_|
                                                                                                                                               " -foregroundcolor "DarkRed"
        Write-Host "                                                                                    Sudo Apt-Get Lambo" -foregroundcolor "Yellow"
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host ""
        $Y = [string]$CoinExchange
	$H = [string]$Currency
	$J = [string]'BTC'
        $BTCExchangeRate = Invoke-WebRequest "https://min-api.cryptocompare.com/data/pricemulti?fsyms=$Y&tsyms=$J" -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty $Y | Select-Object -ExpandProperty $J
       $CurExchangeRate = Invoke-WebRequest "https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC&tsyms=$H" -UseBasicParsing | ConvertFrom-Json | Select-Object -ExpandProperty $J | Select-Object -ExpandProperty $H
        Write-Host "1 $CoinExchange  = $BTCExchangeRate of a Bitcoin" -foregroundcolor "Yellow"
     Write-Host "1 $CoinExchange = " "$Exchanged"  "$Currency" -foregroundcolor "Yellow"
    $Miners | Where {$_.Profit -ge 1E-5 -or $_.Profit -eq $null} | Sort-Object -Descending Type,Profit | Format-Table -GroupBy Type (
        @{Label = "Miner"; Expression={$_.Name}},
        @{Label = "Coin"; Expression={$_.HashRates.PSObject.Properties.Name}},
        @{Label = "Speed"; Expression={$_.HashRates.PSObject.Properties.Value | ForEach {if($_ -ne $null){"$($_ | ConvertTo-Hash)/s"}else{"Bench"}}}; Align='center'},
        @{Label = "BTC/Day"; Expression={$_.Profits.PSObject.Properties.Value | ForEach {if($_ -ne $null){  $_.ToString("N5")}else{"Bench"}}}; Align='right'},
        @{Label = "$Y/Day"; Expression={$_.Profits.PSObject.Properties.Value | ForEach {if($_ -ne $null){  ($_ / $BTCExchangeRate).ToString("N5")}else{"Bench"}}}; Align='right'},
        @{Label = "$Currency/Day"; Expression={$_.Profits.PSObject.Properties.Value | ForEach {if($_ -ne $null){($_ / $BTCExchangeRate * $Exchanged).ToString("N3")}else{"Bench"}}}; Align='center'},
        @{Label = "Algorithm"; Expression={$_.Pools.PSObject.Properties.Value | ForEach {"  $($_.Algorithm)"}}; Align='center'},
        @{Label = " Coin Name"; Expression={$_.Pools.PSObject.Properties.Value | ForEach {"  $($_.Mining)"}}; Align='center'},
        @{Label = "Pool"; Expression={$_.Pools.PSObject.Properties.Value | ForEach {"$($_.Name)"}}; Align='center'}
            ) | Out-Host

#Do nothing for 15 seconds, and check if ccminer is actually running
$CheckMinerInterval = 15
Start-Sleep ($CheckMinerInterval)
$ActiveMinerPrograms | ForEach {
    if($_.Process -eq $null -or $_.Process.HasExited)
    {
        if($_.Status -eq "Running")
	 {
            $_.Failed30sLater++
            if($_.Type -like '*NVIDIA*')
                {
                if($_.Devices -eq $null){$T = "$($_.Arguments)"}
                else
                {
                 if($_.DeviceCall -eq "Ccminer"){$T = "-d $($_.Devices) $($_.Arguments)"}
                 if($_.DeviceCall -eq "EWBF"){$T = "--cuda_devices $($_.Devices) $($_.Arguments)"}
                 if($_.DeviceCall -eq "DSTM"){$T = "--dev $($_.Devices) $($_.Arguments)"}
                 if($_.DeviceCall -eq "claymore"){$T = "-di $($_.Devices) $($_.Arguments)"}
	         if($_.DeviceCall -eq "cuballoon"){$T = "--cuda_devices $($_.Devices) $($_.Arguments)"}
                }
                if($_.Wrap){$_.Process = Start-Process -FilePath "PowerShell" -ArgumentList "-executionpolicy bypass -command . '$(Convert-Path ".\Wrapper.ps1")' -ControllerProcessID $PID -Id '$($_.Port)' -FilePath '$($_.Path)' -ArgumentList "$T" -WorkingDirectory '$(Split-Path $_.Path)'" -PassThru}
                else{$_.Process = Start-SubProcess -FilePath $_.Path -ArgumentList "$T" -WorkingDirectory (Split-Path $_.Path)}
                }
            if($_.Type -eq "CPU")
             {
	     $T = "$($_.Arguments)"
             if($_.Wrap){$_.Process = Start-Process -FilePath "PowerShell" -ArgumentList "-executionpolicy bypass -command . '$(Convert-Path ".\Wrapper.ps1")' -ControllerProcessID $PID -Id '$($_.Port)' -FilePath '$($_.Path)' -ArgumentList "$T" -WorkingDirectory '$(Split-Path $_.Path)'" -PassThru}
             else{$_.Process = Start-SubProcess -FilePath $_.Path -ArgumentList "$T" -WorkingDirectory (Split-Path $_.Path)}
              }
             Start-Sleep ($CheckMinerInterval)
             if($_.Process -eq $null -or $_.Process.HasExited)
              {
               $_.Crashed++
               Write-Host "$($_.Name) Has Fallen And Can't Get up!" -foregroundcolor "darkred"
               if($_.Crashed -le 1)
                {
                 continue
                }
              }
             else
              {
               $_.Recover30sLater++
              }
           }
        }
    }


    #You can examine the difference before and after with:
    ps powershell* | Select *memory* | ft -auto `
    @{Name='Virtual Memory Size (MB)';Expression={($_.VirtualMemorySize64)/1MB}; Align='center'}, `
    @{Name='Private Memory Size (MB)';Expression={(  $_.PrivateMemorySize64)/1MB}; Align='center'},
    @{Name='Memory Used This Session (MB)';Expression={([System.gc]::gettotalmemory("forcefullcollection") /1MB)}; Align='center'}


    #Reduce Memory
    Get-Job -State Completed | Remove-Job
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    [GC]::Collect()


    Write-Host "1 $CoinExchange  = " "$Exchanged" "$Currency" -foregroundcolor "Yellow"

    #Do nothing for a set Interval to allow miner to run
    If ([int]$Interval -gt [int]$CheckMinerInterval) {
	Start-Sleep ($Interval-$CheckMinerInterval)
    }
    else {
        Start-Sleep ($Interval)
    }

    #Save current hash rates
    $ActiveMinerPrograms | foreach {
        if($_.Process -eq $null -or $_.Process.HasExited)
        {
        if($_.Status -eq "Running"){$_.Status = "Failed"}
        }
       else
          {
	  if($TimeDeviation -ne 0)
           {
            Write-Host "MM.Hash is attempting to record hashrate for $($_.Name) $($_.Coins)" -foregroundcolor "blue"
            $_.HashRate = 0
            $_.WasBenchmarked = $False
            $Miner_HashRates = Get-HashRate $_.API $_.Port
            $_.Timeout = 0
	    $_.Benchmarked = 0
            $_.HashRate = $Miner_HashRates
            $WasActive = [math]::Round(((Get-Date)-$_.Process.StartTime).TotalSeconds)
         if($WasActive -ge $StatsInterval)
          {
          Write-Host "$($_.Name) $($_.Coins) Was Active for $WasActive Seconds"
          Write-Host "Attempting to record hashrate for $($_.Name) $($_.Coins)" -foregroundcolor "blue"
          for($i=0; $i -lt 4; $i++)
            {
              if($_.WasBenchmarked -eq $False)
               {
		$HashRateFilePath = Join-Path ".\Stats" "$($_.Name)_$($_.Coins)_HashRate.txt"
                $NewHashrateFilePath = Join-Path ".\Backup" "$($_.Name)_$($_.Coins)_HashRate.txt"
                if(-not (Test-Path (Join-Path ".\Backup" "$($_.Name)_$($_.Coins)_HashRate.txt")))
                 {
                  $Stat = Set-Stat -Name "$($_.Name)_$($_.Coins)_HashRate" -Value $Miner_HashRates
                  Start-Sleep -s 1
		          Write-Host "Stat Written"
                  if(Test-Path (Join-Path ".\Stats" "$($_.Name)_$($_.Coins)_HashRate.txt"))
                  {
                   if (-not (Test-Path ".\Backup")) {New-Item "Backup" -ItemType "directory" | Out-Null}
                   Start-Sleep -s 1
                   Copy-Item $HashrateFilePath -Destination $NewHashrateFilePath
                   $_.New = $False
                   $_.Hashrate_Gathered = $True
                   $_.Crashed = 0
                   $_.WasBenchmarked = $True
                   Write-Host "$($_.Name) $($_.Coins) Was Benchmarked And Backed Up"
                   $_.Timeout = 0
                  }
		  else
                   {
                  $_.Timeout++
                     Write-Host "Timeout Reason 1"
                   }
                  }
                else
                 {
                 $Stat = Set-Stat -Name "$($_.Name)_$($_.Coins)_HashRate" -Value $Miner_HashRates
				 Write-Host "Stat Written"
                 Start-Sleep -s 1
		 $_.New = $False
                 $_.Crashed = 0
                 $_.Hashrate_Gathered = $True
		  if(Test-Path (Join-Path ".\Stats\" "$($_.Name)_$($_.Coins)_HashRate.txt"))
		   {
                    $LastWrite = [datetime](Get-ItemProperty -Path $HashrateFilePath -Name LastWriteTime).LastWriteTime
                    $LastWriteTime = [math]::Round(((Get-Date)-$LastWrite).TotalSeconds)
                    }
                    if($LastWriteTime -le 5)
                     {
                       $_.WasBenchmarked = $True
                       Write-Host "$($_.Name) $($_.Coins) Was Benchmarked."
                       $_.Timeout = 0
                     }
                    else
		     {
                     $_.Timeout++
                     Write-Host "Timeout Reason 2"
                     }
                   }
                }
              }
           }
        }
      }
        if($_.Timeout.Count -ge 0 -or $_.Process -eq $null -or $_.Process.HasExited)
         {
         if($_.WasBenchmarked -eq $False)
          {
	  if($StatsInvterval -lt 2)
	   {
           if(-not (Test-Path (Join-Path ".\Backup" "$($_.Name)_$($_.Coins)_HashRate.txt")))
            {
	    $TimeoutFile = Join-Path ".\Backup" "$($_.Name)_$($_.Coins)_TIMEOUT.txt"
            $Stat = Set-Stat -Name "$($_.Name)_$($_.Coins)_HashRate" -Value 0
            Start-Sleep -s 1
            if (-not (Test-Path ".\Backup")) {New-Item "Backup" -ItemType "directory" | Out-Null}
            Start-Sleep -s 1
            if((Test-Path $TimeoutFile) -eq $false){New-Item -Path ".\Backup" -Name "$($_.Name)_$($_.Coins)_TIMEOUT.txt"  | Out-Null}
            Write-Host "$($_.Name) $($_.Coins) Hashrate Check Timed Out- It Was Noted In Backup Folder" -foregroundcolor "darkred"
            $_.WasBenchmarked = $True
            $_.New = $False
            $_.Hashrate_Gathered = $True
            $_.Crashed = 0
            $_.Timeout = 0
            }
          else
           {
            $TimeoutFile = Join-Path ".\Backup" "$($_.Name)_$($_.Coins)_TIMEOUT.txt"
            $Stat = Set-Stat -Name "$($_.Name)_$($_.Coins)_HashRate" -Value 0
            Start-Sleep -s 1
            if((Test-Path $TimeoutFile) -eq $false){New-Item -Path ".\Backup" -Name "$($_.Name)_$($_.Coins)_TIMEOUT.txt"  | Out-Null}
            $_.WasBenchmarked = $True
            $_.New = $False
            $_.Hashrate_Gathered = $True
            $_.Crashed = 0
            $_.Timeout = 0
            Write-Host "$($_.Name) $($_.Coins) Miner Benchmarking Timed Out. Setting Hashrate to 0" -foregroundcolor "darkred"
            }
           }
          }
         }
        }
    }

  #Stop the log
  Stop-Transcript
  Get-Date | Out-File "TimeTable.txt"
