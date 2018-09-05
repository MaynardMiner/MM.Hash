Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)

##Check for libc
Start-Process ".\Build\Unix\Hive\libc.sh" -wait


Set-Location ".\Build"

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

   if(Test-Path ".\dir.sh")
    {
       Copy-Item ".\dir.sh" -Destination "/usr/bin" -force | Out-Null
       Set-Location "/usr/bin"
       Start-Process "chmod" -ArgumentList "+x dir.sh"
       Set-Location "/"
       Set-Location $CmdDir
       }
