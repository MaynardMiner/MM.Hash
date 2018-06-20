param(
    [Parameter(Mandatory=$false)]
    [String]$Wallet1,
    [Parameter(Mandatory=$false)]
    [array]$Pool
	)

while ($true)
{
  Clear-Host
  
   $Wallet = $Wallet1
   
    if($Pool -eq "zergpool")
     {
    $GetWalletZergpool = Invoke-RestMethod "http://zergpool.com/api/wallet?address=$Wallet" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop

    $GetWalletZergpool | foreach {

    $Get_Zerg_Currency = $_.currency
    $Get_Zerg_Unsold = $_.unsold
    $Get_Zerg_Balance = $_.balance
    $Get_Zerg_Unpaid = $_.unpaid
    $Get_Zerg_24h = $_.paid24h
    $Get_Zerg_Total = $_.total

    Write-Host "
    Zergpool $Wallet
    Currency = $Get_Zerg_Currency
    Unsold = $Get_Zerg_Unsold
    Balance = $Get_Zerg_Balance
    Unpaid = $Get_Zerg_Unpaid
    Total Paid  = $Get_Zerg_24h
    Total Earned = $Get_Zerg_Total"
    }
   }
   
  Start-Sleep -s 1
  
    if($Pool -eq "zpool")
     {
    $GetWalletZpool = Invoke-RestMethod "https://www.zpool.ca/api/wallet?address=$Wallet" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop

    $GetWalletZpool | foreach {
