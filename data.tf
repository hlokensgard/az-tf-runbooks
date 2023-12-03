data "azurerm_storage_account_blob_container_sas" "runbooks" {
  connection_string = azurerm_storage_account.runbooks.primary_connection_string
  container_name    = azurerm_storage_container.runbooks.name
  https_only        = true
  start             = timestamp()
  expiry            = timeadd(timestamp(), "180s")

  permissions {
    read   = true
    write  = false
    delete = false
    list   = false
    add    = false
    create = false
  }
}