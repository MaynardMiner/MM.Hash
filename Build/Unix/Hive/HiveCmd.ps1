function Get-GPUCount {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$DeviceType,
        [Parameter(Mandatory=$true)]
        [String]$CmdDir
    )
    Set-Location "/"
    Set-Location $CmdDir

    $DeviceType | foreach{
     if($_ -like "*NVIDIA*")
      {
       Write-Host "Getting NVIDIA GPU Count" -foregroundcolor cyan
       lspci | Tee-Object ".\GPUCount.txt" | Out-Null
       $GCount = Get-Content ".\GPUCount.txt" 
       $AttachedGPU = $GCount | Select-String "VGA" | Select-String "NVIDIA"   
       [int]$GPU_Count = $AttachedGPU.Count
       }
      if($_ -like "*AMD*")
       {
         Write-Host "Getting AMD GPU Count" -foregroundcolor cyan
         lspci | Tee-Object ".\GPUCount.txt" | Out-Null
         $GCount = Get-Content ".\GPUCount.txt" 
         $AttachedGPU = $GCount | Select-String "VGA" | Select-String "AMD"   
         [int]$GPU_Count = $AttachedGPU.Count
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

    if(Test-Path ".\dir.sh")
     {
      Copy-Item ".\dir.sh" -Destination "/usr/bin" -force | Out-Null
      Set-Location "/usr/bin"
      Start-Process "chmod" -ArgumentList "+x dir.sh"
      Set-Location "/"
      Set-Location $CmdDir
     }

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
    $GetAlgorithms = Get-Content ".\Config\get-pool.txt" | ConvertFrom-Json
    $PoolAlgorithms = @()
    $GetAlgorithms | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | foreach {
     $PoolAlgorithms += $_
    }
    
    if($No_Algo -ne $null)
     {
     $GetNoAlgo = Compare-Object $No_Algo $PoolAlgorithms
     $GetNoAlgo.InputObject | foreach{$AlgorithmList += $_}
     }
     else{$PoolAlgorithms | foreach { $AlgorithmList += $($_)} }
         
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
            [String]$Devices='',
            [parameter(Mandatory=$false)]
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
            [String]$Logs,
            [parameter(Mandatory=$true)]
            [String]$Delay,
            [parameter(Mandatory=$true)]
            [string]$MinerInstance,
            [parameter(Mandatory=$true)]
            [string]$Algos,
            [parameter(Mandatory=$true)]
            [string]$GPUGroups,
            [parameter(Mandatory=$true)]
            [string]$APIs,
            [parameter(Mandatory=$true)]
            [string]$Ports,
            [parameter(Mandatory=$true)]
            [string]$MDir,
            [parameter(Mandatory=$false)]
            [string]$Username,                      
            [parameter(Mandatory=$false)]
            [string]$Connection,
            [parameter(Mandatory=$false)]
            [string]$Password                                           
        )
    
        $MinerTimer = New-Object -TypeName System.Diagnostics.Stopwatch
        $Export = "/hive/ccminer/cuda"         
        Set-Location "/"
        Set-Location $CmdDir
        $PIDMiners = "$($Type)"
        if(Test-Path ".\PID\*$PIDMiners*"){Remove-Item ".\PID\*$PIDMiners*" -Force}
        if($Type -like '*NVIDIA*')
        {
        if($Devices -eq ''){$MinerArguments = "$($Arguments)"}
        else{
        if($DeviceCall -eq "ccminer"){$MinerArguments = "-d $($Devices) $($Arguments)"}
        if($DeviceCall -eq "ewbf"){$MinerArguments = "--cuda_devices $($Devices) $($Arguments)"}
        if($DeviceCall -eq "dstm"){$MinerArguments = "--dev $($Devices) $($Arguments)"}
        if($DeviceCall -eq "claymore"){$MinerArguments = "-di $($Devices) $($Arguments)"}
        if($DeviceCall -eq "trex"){$MinerArguments = "-d $($Devices) $($Arguments)"}
        if($DeviceCall -eq "bminer"){$MinerArgument = "-devices $($Devices) $($Arguments)"}
         }
        }
        if($Type -like '*AMD*')
        {
        if($Devices -eq ''){$MinerArguments = "$($Arguments)"}
        else{
          if($DeviceCall -eq "claymore"){$MinerArguments = "-di $($Devices) $($Arguments)"}
          if($DeviceCall -eq "sgminer"){$MinerArguments = "-d $($Devices) $($Arguments)"}
          if($DeviceCall -eq "tdxminer"){$MinerArguments = "-d $($Devices) $($Arguments)"}
         }
        }
        if($Type -like '*CPU*')
        {
        if($Devices -eq ''){$MinerArguments = "$($Arguments)"}
        else{
          if($DeviceCall -eq "cpuminer-opt"){$MinerArguments = "-t $($Devices) $($Arguments)"}
          if($DeviceCall -eq "cryptozeny"){$MinerArguments = "-t $($Devices) $($Arguments)"}
         }
        }
        if($Type -like '*ASIC*'){$MinerArguments = $Arguments}
   	    $MinerConfig = "./$MinerInstance $MinerArguments"
        $MinerConfig | Set-Content ".\Unix\Hive\config.sh" -Force
        if($Type -eq "NVIDIA1" -or $Type -eq "AMD1")
         {
         Start-Process ".\Unix\Hive\killall.sh" -ArgumentList "LogData" -Wait
         Start-Sleep -S 1
         $DeviceCall | Set-Content ".\Unix\Hive\mineref.sh" -Force
         $Ports | Set-Content ".\Unix\Hive\port.sh" -Force
         Start-Process "screen" -ArgumentList "-S LogData -d -m"    
         Start-Process ".\Unix\Hive\LogData.sh" -ArgumentList "LogData $DeviceCall $Type $GPUGroups $MDir $Algos $APIs $Ports"
         }
         if($Type -eq "CPU")
          {
          if($CPUOnly -eq "Yes")
           {
            $DeviceCall | Set-Content ".\Unix\Hive\mineref.sh" -Force
            $Ports | Set-Content ".\Unix\Hive\port.sh" -Force
            Start-Process ".\Unix\Hive\killall.sh" -ArgumentList "LogData" -Wait
            Start-Sleep -S 1
            Start-Process "screen" -ArgumentList "-S LogData -d -m"    
            Start-Process ".\Unix\Hive\LogData.sh" -ArgumentList "LogData $DeviceCall $Type $GPUGroups $MDir $Algos $APIs $Ports"
           }
          }
       Write-Host "
        
        
        
        Clearing Screen $($Type) & Tracking



        "
        Start-Process ".\Unix\Hive\killall.sh" -ArgumentList "$($Type)" -Wait
        Start-Sleep $Delay #Wait to prevent BSOD
        $MiningId = Start-Process "screen" -ArgumentList "-S $($Type) -d -m"
        Start-Sleep -S 1
        if($DeviceCall -eq "lyclminer"){
        Set-Location $MinerDir
        $ConfFile = Get-Content ".\lyclMiner.conf"
        $NewLines = $ConfFile | ForEach {
        if($_ -like "*<Connection Url =*"){$_ = "<Connection Url = `"stratum+tcp://$Connection`""}
        if($_ -like "*Username =*"){$_ = "            Username = `"$Username`"    "}
        if($_ -like "*Password =*" ){$_ = "            Password = `"$Password`">    "}
        if($_ -notlike "*<Connection Url*" -or $_ -notlike "*Username*" -or $_ -notlike "*Password*"){$_}
        }
        $NewLines | Set-Content ".\lyclMiner.conf"
        Set-Location $CmdDir
        }
        Set-Location $MinerDIr
        Start-Process "chmod" -ArgumentList "+x $MinerInstance" -Wait
        Set-Location $CmdDir
        if($Type  -like '*NVIDIA*'){Start-Process ".\Unix\Hive\pre-start.sh" -ArgumentList "$($Type) $Export" -Wait}
        if($Type -like '*AMD*'){Start-Process ".\Unix\Hive\pre-startamd.sh" -ArgumentList "$($Type)" -Wait}
	    Start-Sleep -S 1
        Write-Host "Starting $($Name) Mining $($Coins) on $($Type)" -ForegroundColor Cyan
	    Start-Process ".\Unix\Hive\startup.sh" -ArgumentList "$MinerDir $($Type) $CmdDir/Unix/Hive $Logs"

        $MinerTimer.Restart()
        $MinerProcessId = $null
        Do{
           Start-Sleep -S 1
           Write-Host "Getting Process ID for $MinerName"           
           $MinerProcessId = Get-Process -Name "$($MinerInstance)" -ErrorAction SilentlyContinue
          }until($MinerProcessId -ne $null -or ($MinerTimer.Elapsed.TotalSeconds) -ge 10)  
        if($MinerProcessId -ne $null)
         {
            $MinerProcessId.Id | Set-Content ".\PID\$($Name)_$($Coins)_$($MinerInstance)_PID.txt" -Force
            Get-Date | Set-Content ".\PID\$($Name)_$($Coins)_$($MinerInstance)_Date.txt" -Force
            Start-Sleep -S 1
        }
        $MinerTimer.Stop()
        Rename-Item "$MinerDir\$($MinerInstance)" -NewName "$MinerName" -Force
        Start-Sleep -S 1
        Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
    }

    function Get-PID {
        param(
            [parameter(Mandatory=$false)]
            [String]$Instance,          
	    [parameter(Mandatory=$false)]
            [String]$Type,
	    [parameter(Mandatory=$false)]
            [String]$InstanceNum
            )
    
        $GetPID = "$($Instance)_PID.txt"
        
        if(Test-Path $GetPID)
         {
	  $PIDName = "$($Instance)-$($InstanceNum)"
          $PIDNumber = Get-Content $GetPID
          $MinerPID = Get-Process -Id $PIDNumber -erroraction SilentlyContinue
 	  if($MinerPID -eq $Null){$MinerPID = Get-Process -Name $PIDName -erroraction SilentlyContinue}
         }
        else{$MinerPID = $null}

        $MinerPID

    }
    
