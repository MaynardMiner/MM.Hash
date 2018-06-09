param(
    [Parameter(Mandatory=$false)]
    [String]$Wallet
	)

while ($true)
{
  Clear-Host
    $GetWallet = Invoke-RestMethod http://zergpool.com/api/wallet?address=RKirUe978mBoa2MRWqeMGqDzVAKTafKh8H -UseBasicParsing

    $GetWallet | foreach {

    $Get_Currency = $_.currency
    $Get_Unsold = $_.unsold
    $Get_Balance = $_.balance
    $Get_Unpaid = $_.unpaid
    $Get_24h = $_.paid24h
    $Get_Total = $_.total

    Write-Host "
    Currency = $Get_Currency
    Unsold = $Get_Unsold
    Balance = $Get_Balance
    Unpaid = $Get_Unpaid
    Total Paid  = $Get_24h
    Total Earned = $Get_Total"

    }

    Start-Sleep -s 240
}
