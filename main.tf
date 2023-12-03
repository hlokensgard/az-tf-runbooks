resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_automation_account" "this" {
  name                = var.automation_account_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  sku_name = "Basic"
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azapi_resource" "runbook" {
  type                      = "Microsoft.Automation/automationAccounts/runbooks@2023-11-01"
  name                      = var.runbook_name
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
        uri = "https://${azurerm_storage_account.runbooks.name}.blob.core.windows.net/${azurerm_storage_container.runbooks.name}/${azurerm_storage_blob.runbooks.name}${data.azurerm_storage_account_blob_container_sas.runbooks.sas}"
      }
    }
  })

  response_export_values = ["*"]
  tags                   = var.tags
}

# Uploading modules to the automation account for version 5.1
resource "azapi_resource" "automation_account_pre_req_modules" {
  for_each  = var.powershell_version == "7.2" ? {} : (local.prerequisites_modules == null ? {} : local.prerequisites_modules)
  type      = "Microsoft.Automation/automationAccounts/modules@2022-08-08"
  name      = each.value.name
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_automation_account.this.id
  tags      = var.tags
  body = jsonencode({
    properties = {
      contentLink = {
        uri     = each.value.uri
        version = each.value.version
      }
    }
  })
}

resource "azapi_resource" "automation_account_modules" {
  depends_on = [azapi_resource.automation_account_pre_req_modules]
  for_each   = var.powershell_version == "7.2" ? {} : (local.modules == null ? {} : local.modules)
  type       = "Microsoft.Automation/automationAccounts/modules@2022-08-08"
  name       = each.value.name
  location   = azurerm_resource_group.this.location
  parent_id  = azurerm_automation_account.this.id
  tags       = var.tags
  body = jsonencode({
    properties = {
      contentLink = {
        uri     = each.value.uri
        version = each.value.version
      }
    }
  })
}

# Storage account
# Storage account for the runbook
# This is nessesary to because we need to use the azapi resource
# This only supports uploading the runbook with an URI
# Recommend to delete the storage account when the upload is done
# This can be done in a post step in your CICD pipeliene
resource "azurerm_storage_account" "runbooks" {
  name                     = random_string.sa_name.result
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Need this to be true for the azapi resource to work
  # Create a SAS token for the runbook
  shared_access_key_enabled = true
  # This can be set to false, but then you need to
  # add the IP address for the automation account to the firewall rules for the storage account
  # these can be found in run-time when the runbook runs.
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 1 # Since I recommend to delete the storage account when the upload is done
    }
    container_delete_retention_policy {
      days = 1 # Since I recommend to delete the storage account when the upload is done
    }
  }

  network_rules {
    default_action = "Allow"
    bypass         = ["None"]
  }

  immutability_policy {
    allow_protected_append_writes = false
    state                         = "Disabled"
    period_since_creation_in_days = 0
  }
}

resource "azurerm_storage_container" "runbooks" {
  name                  = "runbooks"
  storage_account_name  = azurerm_storage_account.runbooks.name
  container_access_type = "private"
}

# Creates a random string for the storage account
resource "random_string" "sa_name" {
  length  = 12
  special = false
  upper   = false
  lower   = true
}

# To use powershell 7 we need to use the azapi provider.
# The provider only supports URI location for the runbooks.
# Uploading the runbook to a storage account and using the URI is the easiest way to do this.
resource "azurerm_storage_blob" "runbooks" {
  name                   = "Runbook"
  storage_account_name   = azurerm_storage_account.runbooks.name
  storage_container_name = azurerm_storage_container.runbooks.name
  type                   = "Block" # Changing this forces a new resource to be created.
  access_tier            = "Hot"
  source                 = var.runbook_file_path
  content_md5            = filemd5(var.runbook_file_path)
}
