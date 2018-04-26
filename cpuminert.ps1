function Start-Subprocess {
         param(
        [Parameter(Mandatory=$true)]
        [String]$FilePath,
        [Parameter(Mandatory=$false)]
        [String]$ArgumentList = ""
         )

$Job = Start-Job -ArgumentList $PID, FilePath, $ArgumentList -Scriptblock {
       param($ControllerProcessID, $FilePath, $ArgumentList)

       $ControllerProcess = Get-Process -Id $ControllerProcessID
       if($ControlerProcess -eq $null){return}
        
       $ProcessParam = @{}
       $ProcessParam.Add("FilePath", $FilePath)
       if($ArgumentList -ne ""){$ProcessParam.Add("ArgumentList", $ArgumentList)}      
       $Process = Start-Process @ProcessParam -PassThru
       if($Process -eq $null){[PSCustomObject]@{ProcessId = $null}; return}

        [PSCustomObject]@{ProcessId = $Process.Id; ProcessHandle = $Process.Handle}


       $ControllerProcess.Handle | Out-Null
        $Process.Handle | Out-Null

        do{if($ControllerProcess.WaitForExit(1000)){$Process.CloseMainWindow() | Out-Null}}
        while($Process.HasExited -eq $false)
    }

    do{Start-Sleep 1; $JobOutput = Start-Job $Job}
    while($JobOutput -eq $null)

    $Process = Get-Process | Where Id -EQ $JobOutput.ProcessId
    $Process.Handle | Out-Null
    $Process
}


Set-Location /home/maynard/MM.Hash/Bin/CPU-JayDDee
Start-SubProcess -Filepath "xterm" -ArgumentList "-e ./cpuminer -a yescrypt -o stratum+tcp://yescrypt.mine.zergpool.com:6233 -u RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H -p c=RVN"
