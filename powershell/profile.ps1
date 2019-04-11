# Place profile.ps1 in C:\Users\username\Documents\WindowsPowerShell
# Set default location of my Powershell scripts.
Set-Location C:\Users\username\Powershell

$host.PrivateData.ErrorBackgroundColor = "DarkCyan"
$host.PrivateData.ErrorForegroundColor = "Yellow"
$foregroundColor = "DarkGreen"

# Allow to autoamatically load and login to Azure account.
function Load-Subscriptions { 
    [cmdletbinding()]
    param()

    ##########################################
    #             Azure  Menu                #
    ##########################################
   
    Write-Host `n"Chose Azure Subscription " -ForegroundColor $foregroundColor -BackgroundColor Cyan
    Write-Host `n"Type 'q' or hit enter to drop to shell"`n
    Write-Host -NoNewLine "<" -ForegroundColor $foregroundColor
    Write-Host -NoNewLine "Please Select:"
    Write-Host -NoNewLine ">" -ForegroundColor $foregroundColor
    Write-Host -NoNewLine "["
    Write-Host -NoNewLine "]"

    Write-Host -NoNewLine `t`n "1 - " -ForegroundColor $foregroundColor
    Write-host -NoNewLine "First Subscription"
    Write-Host -NoNewLine `t`n "2 - " -ForegroundColor $foregroundColor
    Write-host -NoNewLine "Second Subscription"
    Write-Host -NoNewLine `t`n "2 - " -ForegroundColor $foregroundColor
    Write-host -NoNewLine "Private Subscription"
    Write-Host -NoNewLine `t`n 
    
    
    $choice = Read-Host "Which option?"

    if ($choice.Count -gt 0) {

        switch ($choice) {
            "1" {Load-Profile('First')}
            "2" {Load-Profile("Second")}
            "3" {Load-Profile('Private')}
            {($_ -like "*q*") -or ($_ -eq "")} {
                Write-Host `n"Dropping to shell" -ForegroundColor $foregroundColor
                Write-Host "Type Load-Subscriptions to load this menu again"`n -ForegroundColor $foregroundColor            
            }
            Default {(Load-Subscriptions)}
        }
    }
    ##########################################
    #            End Azure Menu              #
    ##########################################
}
Function Load-Profile($profile) {
    if ($choice.Count -eq 0) {
        Write-Host `n"Dropping to shell." -ForegroundColor $foregroundColor
    } elseif ($profile -eq "First") {
        Write-Host `n"Loaded First Azure Profile" -ForegroundColor $foregroundColor
        Import-AzContext -Path  C:\Users\user\.Azure\AzureAuthfile-first.json
    } elseif ($profile -eq "Second") {
        Write-Host `n"Loaded Second Azure Profile" -ForegroundColor $foregroundColor
        Import-AzContext -Path  C:\Users\user\.Azure\AzureAuthfile-second.json
    } else {
        Write-Host `n"Loaded Private Azure Profile" -ForegroundColor $foregroundColor
        Import-AzContext -Path  C:\Users\user\.Azure\AzureAuthfile-private.json
    }
}
Load-Subscriptions
