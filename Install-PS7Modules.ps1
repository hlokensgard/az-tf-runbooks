$ErrorActionPreference = "Stop"

function Connect-AutomationAccountWithManagedIdentity {
    [CmdletBinding()]
    param()
    try {
        # Authenticate to Azure if running from Azure Automation
        if ($PSPrivateMetadata.JobId) {
            Write-Output "`n`nAuthenticating to Azure with the automation account's System Assigned Managed Identity ..."
            # Ensures you do not inherit an AzContext in your runbook
            Write-Output "Disable AzContextAutosave ..."
            $null = Disable-AzContextAutosave -Scope Process -ErrorAction SilentlyContinue

            # Accept five minutes of retries to log in.
            Write-Output "Try to connect to Azure ..."
            $logonAttempt = 0
            while (!($connectionResult) -and ($logonAttempt -le 10)) {
                $LogonAttempt++
                # The automation account has a System Assigned Managed Identity
                $connectionResult = Connect-AzAccount -Identity
                Start-Sleep -Seconds 30
            }
        }
        Write-Output "Setting the context to the subscription ..."
        $subscriptionId = (Get-AutomationVariable -Name "SubscriptionId")
        $null = Select-AzSubscription -SubscriptionId $subscriptionId
        Write-Output "Context set to the subscription: $subscriptionId"
    }
    catch {
        Write-Output "Error occured while connecting to Azure with 'Connect-AzAccount'."
        Write-Output "Error message: $($_)"
    }
}

function Install-Module {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Modules,
        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountName,
        [Parameter(Mandatory = $true)]
        [string]$AutomationAccountResourceGroupName
    )

    $createRunbookParam = @{
        Method               = "PUT"
        ResourceGroupName    = $AutomationAccountResourceGroupName
        ResourceProviderName = "Microsoft.Automation"
        ResourceType         = "automationAccounts"
        ApiVersion           = '2019-06-01&runtimeVersion=7.2'
    }

    $moduleEndpoint = @{
        '7.2' = 'powershell7Modules'
        '5.1' = 'Modules'
    }

    $Modules.GetEnumerator()  | ForEach-Object {
        $moduleName = $_.value.name
        # payload with uri for module from gallery
        $modulePayload = @{
            properties = @{
                contentLink = @{
                    uri = "$($_.value.uri)/$($_.value.version)"
                }
            }
        } | ConvertTo-Json -Compress

        try {
            Write-Output "Installing the module '$($moduleName)' with version $($_.value.version) to the automation account '$AutomationAccountName'."
            $null = Invoke-AzRestMethod @createRunbookParam -Name "$($AutomationAccountName)/$($moduleEndpoint["7.2"])/$($moduleName)" -Payload $modulePayload
            Write-Output "Waiting for 5 seconds ..."
            Start-Sleep -Seconds 5
        }
        catch {
            Write-Output "Error occured while installing the module '$($_.value.name)' with version $($_.value.version) to the automation account '$AutomationAccountName'."
            Write-Output "Error message: $($_)"
        }
    }

    $createRunbookParam.Method = "GET"

    try {
            $Modules.GetEnumerator()  | ForEach-Object {
                $moduleName = $_.value.name
                do {
                    $moduleStatus = Invoke-AzRestMethod @createRunbookParam -Name "$($AutomationAccountName)/$($moduleEndpoint["7.2"])/$($moduleName)"
                    $moduleStatus = $moduleStatus.Content | ConvertFrom-Json -AsHashtable

                    Write-Output "  - Waiting for the module: $($moduleName) to be installed ..."
                    Write-Output "  - Waiting for 30 seconds ..."
                    Start-Sleep -Seconds 30
                } while ($moduleStatus.properties.provisioningState -ne "Succeeded")
                Write-Output "  - Module '$($moduleName)' with version $($_.value.version) installed."
                Write-Output "  - Status: $($moduleStatus.properties.provisioningState)"
            }
    }
    catch {
            Write-Output "Error occured while waiting for the modules to be installed."
            Write-Output "Error message: $($_)"
    }
}

function Install-Powershell72Modules {
    [CmdletBinding()]
    param()
    $automationAccountName = (Get-AutomationVariable -Name "AutomationAccountName")
    $automationAccountResourceGroupName = (Get-AutomationVariable -Name "AutomationAccountResourceGroupName")
    $prerequisitesModuleInfo = (Get-AutomationVariable -Name "powershell_modules_prerequisites") | ConvertFrom-Json -AsHashtable
    $moduleInfo = (Get-AutomationVariable -Name "powershell_modules") | ConvertFrom-Json -AsHashtable

    Write-Output "Installing the prerequisites modules ..."
    Install-Module -Modules $prerequisitesModuleInfo -AutomationAccountName $automationAccountName -AutomationAccountResourceGroupName $automationAccountResourceGroupName -Verbose
    Write-Output "Installing the modules ..."
    Install-Module -Modules $moduleInfo -AutomationAccountName $automationAccountName -AutomationAccountResourceGroupName $automationAccountResourceGroupName -Verbose
    Write-Output "All modules installed."
}

try {
    Write-Output "Connecting to Azure ..."
    Connect-AutomationAccountWithManagedIdentity -Verbose
}
catch {
    Write-Output "Error occured while connecting to Azure with 'Connect-AutomationAccountWithManagedIdentity'."
    Write-Output "Error message: $($_)"
}
try {
    Write-Output "Installing PowerShell 7.2 modules ..."
    Install-Powershell72Modules -Verbose
}
catch {
    Write-Output "Error occured while installing PowerShell 7.2 modules with 'Install-Powershell72Modules'."
    Write-Output "Error message: $($_)"
}