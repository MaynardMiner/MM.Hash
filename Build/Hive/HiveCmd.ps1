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
        nvidia-smi -a | Tee-Object ".\Build\GPUCount.txt" | Out-Null
        $GCount = Get-Content ".\Build\GPUCount.txt" 
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

    Write-Host "$CmdDir"
    if(Test-Path ".\Build\stats")
    {
         Copy-Item ".\Build\stats" -Destination "/usr/bin" -force | Out-Null
         Set-Location "/usr/bin"
         Start-Process "chmod" -ArgumentList "+x stats"
         Set-Location "/"
         Set-Location $CmdDir     
    }
   
   if(Test-Path ".\Build\active")
    {
       Copy-Item ".\Build\active" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x active"
       Set-Location "/"
       Set-Location $CmdDir
       }
   
   if(Test-Path ".\Build\mine")
    {
       Copy-Item ".\Build\mine" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x mine"
       Set-Location "/"
       Set-Location $CmdDir
       }
   
   if(Test-Path ".\Build\logdata")
    {
       Copy-Item ".\Build\logdata" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x logdata"
       Set-Location "/"
       Set-Location $CmdDir
       }
   
   if(Test-Path ".\Build\pidinfo")
    {
       Copy-Item ".\Build\pidinfo" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x pidinfo"
       Set-Location "/"
       Set-Location $CmdDir
       }
    

    if((Get-Item ".\Build\Data\Info.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Build\Data\" -Name "Info.txt"  | Out-Null}
   if((Get-Item ".\Build\Data\System.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Build\Data" -Name "System.txt"  | Out-Null}
   if((Get-Item ".\Build\Data\TimeTable.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Build\Data" -Name "TimeTable.txt"  | Out-Null}
    if((Get-Item ".\Build\Data\Error.txt" -ErrorAction SilentlyContinue) -eq $null)
    {New-Item -Path ".\Build\Data" -Name "Error.txt"  | Out-Null}
    $TimeoutClear = Get-Content ".\Build\Data\Error.txt" | Out-Null
    if(Test-Path ".\Build\PID"){Remove-Item ".\Build\PID\*" -Force | Out-Null}
    else{New-Item -Path ".\Build" -Name "PID" -ItemType "Directory" | Out-Null}   
    if($TimeoutClear -ne "")
     {
      Clear-Content ".\Build\Data\System.txt"
      Get-Date | Out-File ".\Build\Data\Error.txt" | Out-Null
     } 

    $DonationClear = Get-Content ".\Build\Data\Info.txt" | Out-String
    if($DonationClear -ne "")
    {Clear-Content ".\Build\Data\Info.txt"} 
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
        if($_ -like "*AMD*"){$GetAlgorithms = Get-Content ".\Coinfig\amd-algorithms.txt"}
        if($No_Algo -ne $null)
         {
         $GetNoAlgo = Compare-Object $No_Algo $GetAlgorithms
         $GetNoAlgo.InputObject | foreach{$AlgorithmList += $_}
         }
         else{$GetAlgorithms | foreach { $AlgorithmList += $($_)} }
        }
    
    $AlgorithmList
    }
