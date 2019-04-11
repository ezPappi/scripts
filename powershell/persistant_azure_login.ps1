# Install the Azure Powershell module.
Install-Module -Name Az -AllowClobber

# Check what you installed.
Get-Module -ListAvailable Az.* | Select Name, Version

# Connect to Azure.
Connect-AzAccount

# Reuse Azure Authentication in order to avoid the steps of re-opening the browser.
Save-AzContext -Path C:\path\to\\AzureAuthfile.json

# After exiting your PowerShell session, in order to reconnect again load authentication information from a file.
Import-AzContext -Path C:\path\to\\AzureAuthfile.json

# Allow the azure credential, account and subscription information to be saved and automatically loaded when you open a PowerShell window.
Enable-AzContextAutoSave

# Or don't.
Disable-AzContextAutoSave
