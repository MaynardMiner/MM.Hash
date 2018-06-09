. .\Include.ps1

try
{
    $MiningPoolHub_Request = Invoke-WebRequest "https://miningpoolhub.com/index.php?page=api&action=getautoswitchingandprofitsstatistics" -UseBasicParsing | ConvertFrom-Json
}
catch
{
    return
}

if(-not $MiningPoolHub_Request.success)
{
    return
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Locations = 'Europe', 'US', 'Asia'

$Locations | ForEach-Object {
    $Location = $_

    $MiningPoolHub_Request.return | ForEach-Object {
        $Algorithm = $_.algo -replace "-"
        $Coin = (Get-Culture).TextInfo.ToTitleCase(($_.current_mining_coin -replace "-", " ")) -replace " "
        $Fees = .9
        $Stat = Set-Stat -Name "$($Name)_$($Algorithm)_Profit" -Value ([decimal]$_.profit/1000000000)
        $Price = (($Stat.Live*(1-[Math]::Min($Stat.Day_Fluctuation,1)))+($Stat.Day*(0+[Math]::Min($Stat.Day_Fluctuation,1))))
        
        [PSCustomObject]@{
            Algorithm = $Algorithm
            Info = $Coin
            Fees = $Fees 
            Price = $Price
            Workers = 'N/A'
            StablePrice = $Stat.Week
            Protocol = 'stratum+tcp'
            Host = $_.all_host_list.split(";") | Sort-Object -Descending {$_ -ilike "$Location*"} | Select-Object -First 1
            Port = $_.algo_switch_port
            User = '$UserName.$WorkerName'
	    User1 = '$UserName.$WorkerName'
	    User2 = '$UserName.$WorkerName'
	    User3 = '$UserName.$WorkerName'
            User4 = '$UserName.$WorkerName'
            User5 = '$UserName.$WorkerName'
            User6 = '$UserName.$WorkerName'
            User7 = '$UserName.$WorkerName'
	    User8 = '$UserName.$WorkerName'
            Pass = 'x'
	    Pass1 = 'x'
  	    Pass2 = 'x'
	    Pass3 = 'x'
	    Pass4 = 'x'
            Pass5 = 'x'
            Pass6 = 'x'
            Pass7 = 'x'
            Pass8 = 'x'
            Location = $Location
            SSL = $false
        }
        
        [PSCustomObject]@{
            Algorithm = $Algorithm
            Info = $Coin
            Price = $Price
            Fees = $Fees
            StablePrice = $Stat.Week
            Protocol = 'stratum+ssl'
            Host = $_.all_host_list.split(";") | Sort-Object -Descending {$_ -ilike "$Location*"} | Select-Object -First 1
            Port = $_.algo_switch_port
            User = '$UserName.$WorkerName'
	    User1 = '$UserName.$WorkerName'
	    User2 = '$UserName.$WorkerName'
	    User3 = '$UserName.$WorkerName'
            User4 = '$UserName.$WorkerName'
            User5 = '$UserName.$WorkerName'
            User6 = '$UserName.$WorkerName'
            User7 = '$UserName.$WorkerName'
	    User8 = '$UserName.$WorkerName'
            Pass = 'x'
	    Pass1 = 'x'
  	    Pass2 = 'x'
	    Pass3 = 'x'
	    Pass4 = 'x'
            Pass5 = 'x'
            Pass6 = 'x'
            Pass7 = 'x'
            Pass8 = 'x'
            Location = $Location
            SSL = $true
        }
    }
}
