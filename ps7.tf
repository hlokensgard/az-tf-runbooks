# Upload the script
resource "azapi_resource" "runbook_ps7_moduels" {
  count                     = var.powershell_version == "7.2" ? 1 : 0
  type                      = "Microsoft.Automation/automationAccounts/runbooks@2023-11-01"
  name                      = "Install-PowerShell-7.1-Modules"
  parent_id                 = azurerm_automation_account.this.id
  location                  = azurerm_resource_group.this.location
  schema_validation_enabled = false # Required because this resource won't validate

  body = jsonencode({
    properties = {
      runbookType      = local.current_powershell_version
      logVerbose       = false
      logProgress      = false
      logActivityTrace = 0
      publishContentLink = {
        uri = "https://${azurerm_storage_account.runbooks.name}.blob.core.windows.net/${azurerm_storage_container.runbooks.name}/${azurerm_storage_blob.modules[0].name}${data.azurerm_storage_account_blob_container_sas.runbooks.sas}"
      }
    }
  })

  response_export_values = ["*"]
  tags                   = var.tags
}

resource "azurerm_storage_blob" "modules" {
  count                  = var.powershell_version == "7.2" ? 1 : 0
  name                   = "Intall-PowerShell-7.2-Modules"
  storage_account_name   = azurerm_storage_account.runbooks.name
  storage_container_name = azurerm_storage_container.runbooks.name
  type                   = "Block" # Changing this forces a new resource to be created.
  access_tier            = "Hot"
  source                 = "${path.module}/Install-PS7Modules.ps1"
  content_md5            = filemd5("${path.module}/Install-PS7Modules.ps1")
}

locals {
  automation_account_variables_strings = {
    "SubscriptionId" = {
      "description" = "The subscription id for the automation account"
      "value"       = var.subscription_id
    },
    "AutomationAccountName" = {
      "description" = "The name of the automation account"
      "value"       = azurerm_automation_account.this.name
    },
    "AutomationAccountResourceGroupName" = {
      "description" = "The resource group name for the automation account"
      "value"       = azurerm_resource_group.this.name
    },
    "powershell_modules_prerequisites" = {
      "description" = "Installing prequisites modules for the automation account when running powershell 7.2"
      "value"       = jsonencode(local.prerequisites_modules)
    },
    "powershell_modules" = {
      "description" = "Installing modules for the automation account when running powershell 7.2"
      "value"       = jsonencode(local.modules)
    }
  }
}

resource "azurerm_automation_variable_string" "this" {
  for_each                = var.powershell_version == "7.2" ? local.automation_account_variables_strings : {}
  name                    = each.key
  resource_group_name     = azurerm_automation_account.this.resource_group_name
  automation_account_name = azurerm_automation_account.this.name
  description             = each.value.description
  encrypted               = false
  value                   = each.value.value
}

# Set a one-time schedule to run it at once
resource "azurerm_automation_schedule" "one_time" {
  count                   = var.powershell_version == "7.2" ? 1 : 0
  name                    = "${azapi_resource.runbook_ps7_moduels[0].name}-one-time"
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  frequency               = "OneTime"

  // The start_time defaults to now + 7 min
}

resource "azurerm_automation_job_schedule" "one_time" {
  count                   = var.powershell_version == "7.2" ? 1 : 0
  resource_group_name     = azurerm_resource_group.this.name
  automation_account_name = azurerm_automation_account.this.name
  runbook_name            = azapi_resource.runbook_ps7_moduels[0].name
  schedule_name           = azurerm_automation_schedule.one_time[0].name
}
