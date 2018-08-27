function Get-GPUCount {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$DeviceType,
        [Parameter(Mandatory=$true)]
        [String]$CmdDir
    )
    Set-Location "/"
    Set-Location $CmdDir

    $DeviceType = "NVIDIA1"

    $DeviceType | foreach{
     if($_ -like "*NVIDIA*")
      {
       Write-Host "Getting NVIDIA GPU Count" -foregroundcolor cyan
        nvidia-smi -a | Tee-Object ".\GPUCount.txt" | Out-Null
        $GCount = Get-Content ".\GPUCount.txt" 
        $AttachedGPU = $GCount | Select-String "Attached GPUS"   
        [int]$GPU_Count = $AttachedGPU -split ": " | Select -Last 1
         }
        }
    $GPU_Count  
}

function Get-Data {
    param (
    [Parameter(Mandatory=$true)]
    [String]$CmdDir
    )

    Set-Location "/"
    Set-Location $CmdDir

    if(Test-Path ".\stats")
    {
         Copy-Item ".\stats" -Destination "/usr/bin" -force | Out-Null
         Set-Location "/usr/bin"
         Start-Process "chmod" -ArgumentList "+x stats"
         Set-Location "/"
         Set-Location $CmdDir     
    }
   
   if(Test-Path ".\active")
    {
       Copy-Item ".\active" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x active"
       Set-Location "/"
       Set-Location $CmdDir
       }
    
       if(Test-Path ".\get-screen")
    {
       Copy-Item ".\get-screen" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x get-screen"
       Set-Location "/"
       Set-Location $CmdDir
       }
   
   if(Test-Path ".\mine")
    {
       Copy-Item ".\mine" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x mine"
       Set-Location "/"
       Set-Location $CmdDir
       }
   
   if(Test-Path ".\logdata")
    {
       Copy-Item ".\logdata" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x logdata"
       Set-Location "/"
       Set-Location $CmdDir
       }
   
   if(Test-Path ".\pidinfo")
    {
       Copy-Item ".\pidinfo" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x pidinfo"
       Set-Location "/"
       Set-Location $CmdDir
       }
    

    if((Get-Item ".\Data\Info.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Data" -Name "Info.txt"  | Out-Null}
   if((Get-Item ".\Data\System.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Data" -Name "System.txt"  | Out-Null}
   if((Get-Item ".\Data\TimeTable.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Data" -Name "TimeTable.txt"  | Out-Null}
    if((Get-Item ".\Data\Error.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Data" -Name "Error.txt"  | Out-Null}
    $TimeoutClear = Get-Content ".\Data\Error.txt" | Out-Null
    if(Test-Path ".\PID"){Remove-Item ".\PID\*" -Force | Out-Null}
    else{New-Item -Path "." -Name "PID" -ItemType "Directory" | Out-Null}   
    if($TimeoutClear -ne "")
     {
      Clear-Content ".\Data\System.txt"
      Get-Date | Out-File ".\Data\Error.txt" | Out-Null
     } 

    $DonationClear = Get-Content ".\Data\Info.txt" | Out-String
    if($DonationClear -ne "")
    {Clear-Content ".\Data\Info.txt"} 
    Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
}

function Get-AlgorithmList {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$DeviceType,
        [Parameter(Mandatory=$true)]
        [String]$CmdDir,
        [Parameter(Mandatory=$false)]
        [Array]$No_Algo
    )
    Set-Location "/"
    Set-Location $CmdDir

    $AlgorithmList = @()

    $Type | foreach {
        if($_ -like "*NVIDIA*"){$GetAlgorithms = Get-Content ".\Config\nvidia-algorithms.txt"}
        if($_ -like "*CPU*"){$GetAlgorithms = Get-Content ".\Config\cpu-algorithms.txt"}
        if($_ -like "*AMD*"){$GetAlgorithms = Get-Content ".\Config\amd-algorithms.txt"}
        if($No_Algo -ne $null)
         {
         $GetNoAlgo = Compare-Object $No_Algo $GetAlgorithms
         $GetNoAlgo.InputObject | foreach{$AlgorithmList += $_}
         }
         else{$GetAlgorithms | foreach { $AlgorithmList += $($_)} }
        }
    
    $AlgorithmList
    Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
    }

 function Start-LaunchCode {
        param(
            [parameter(Mandatory=$true)]
            [String]$Type,
            [parameter(Mandatory=$true)]
            [String]$Name,
            [parameter(Mandatory=$false)]
            [String]$DeviceCall,
            [parameter(Mandatory=$false)]
            [String]$Devices = $null,
            [parameter(Mandatory=$true)]
            [String]$Arguments,
            [parameter(Mandatory=$true)]
            [String]$MinerName,
            [parameter(Mandatory=$true)]
            [String]$Path,
            [parameter(Mandatory=$true)]
            [String]$Coins,
            [parameter(Mandatory=$true)]
            [String]$CmdDir,
            [parameter(Mandatory=$true)]
            [String]$MinerDir,
            [parameter(Mandatory=$true)]
            [String]$Delay,
            [parameter(Mandatory=$true)]
            [String]$Logs
        )
    
        $MinerTimer = New-Object -TypeName System.Diagnostics.Stopwatch
        $Export = "/hive/ccminer/cuda"
	$ClayMinerDir = Join-path "$MinerDir" "$MinerName"
        
        Set-Location "/"
        Set-Location $CmdDir
        $PIDMiners = "$($Type)"
        if(Test-Path ".\PID\*$PIDMiners*"){Remove-Item ".\PID\*$PIDMiners*" -Force}

        if($Type -like '*NVIDIA*')
        {
        if($Devices -eq $null){$MinerArguments = "$($Arguments)"}
        else{
        if($DeviceCall -eq "ccminer"){$MinerArguments = "-d $($Devices) $($Arguments)"}
        if($DeviceCall -eq "ewbf"){$MinerArguments = "--cuda_devices $($Devices) $($Arguments)"}
        if($DeviceCall -eq "dstm"){$MinerArguments = "--dev $($Devices) $($Arguments)"}
        if($DeviceCall -eq "claymore"){$MinerArguments = "-di $($Devices) $($Arguments)"}
        if($DeviceCall -eq "trex"){$MinerArguments = "-d $($Devices) $($Arguments)"}
        }
        }
        if($Type -like '*CPU*'){$MinerArguments = $Arguments}
        if($Type -like '*AMD*'){$MinerArguments = $Arguments}
        if($Type -like '*ASIC*'){$MinerArguments = $Arguments}
	if($MinerName -like '*clay*'){$MinerConfig = "$ClayMinerDir $MinerArguments"}
        else{$MinerConfig = "$Minername $MinerArguments"}
        $MinerConfig | Set-Content ".\Unix\Hive\config.sh"
        Start-Sleep -S 1
        Write-Host "
        
        
        
        Clearing Screen $($_.Type) & Tracking
    
    
    
        "
        Start-Process ".\Unix\Hive\killall.sh" -ArgumentList "$($Type)" -Wait    
        Start-Sleep $Delay #Wait to prevent BSOD
        $MiningId = Start-Process "screen" -ArgumentList "-S $($Type) -d -m"
        Start-Sleep -S 1
        if($Type  -like '*NVIDIA*'){$PreStart = Start-Process ".\Unix\Hive\pre-start.sh" -ArgumentList "$($Type) $Export" -Wait}
        if($Type -like '*AMD*'){$PreStart = Start-Process ".\Unix\Hive\pre-startamd.sh" -ArgumentList "$($Type)" -Wait}
	Start-Sleep -S 1
        Write-Host "Starting $($Name) Mining $($Coins) on $($Type)" -ForegroundColor Cyan
	if($MinerName -like '*clay*'){$NewMiner = Start-Process ".\Unix\Hive\startupclay.sh" -ArgumentList "$($Type) $CmdDir/Unix/Hive"}
	else{$NewMiner = Start-Process ".\Unix\Hive\startup.sh" -ArgumentList "$MinerDir $($Type) $CmdDir/Unix/Hive $Logs"}

        $MinerTimer.Restart()

        Do{
           Start-Sleep -S 1
           Write-Host "Getting Process ID for $MinerName"
           $MinerProcessId = Get-Process -Name "$($MinerName)" -ErrorAction SilentlyContinue
          }until($MinerProcessId -ne $null -or ($MinerTimer.Elapsed.TotalSeconds) -ge 10)  
        if($MinerProcessId -ne $null)
         {
            $MinerProcessId.Id | Out-File ".\PID\$($Name)_$($Coins)_$($Type)_PID.txt"
            Get-Date | Out-File ".\PID\$($Name)_$($Coins)_$($Type)_Date.txt"
            Start-Sleep -S 1
        }

        $MinerTimer.Stop()
        Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)

    }
