param(
    [Parameter(Mandatory=$false)]
    [String]$Wallet,
    [Parameter(Mandatory=$false)]
    [array]$Pool
	)

while ($true)
{
  Clear-Host
    if($Pool -eq "zergpool")
     {
    $GetWalletZergpool = Invoke-RestMethod http://zergpool.com/api/wallet?address=$Wallet -UseBasicParsing

    $GetWallet | foreach {

    $Get_Currency = $_.currency
    $Get_Unsold = $_.unsold
    $Get_Balance = $_.balance
    $Get_Unpaid = $_.unpaid
    $Get_24h = $_.paid24h
    $Get_Total = $_.total

    Write-Host "
    Zergpool Wallet
    Currency = $Get_Currency
    Unsold = $Get_Unsold
    Balance = $Get_Balance
    Unpaid = $Get_Unpaid
    Total Paid  = $Get_24h
    Total Earned = $Get_Total"
    }
   }

    Start-Sleep -s 300
}
