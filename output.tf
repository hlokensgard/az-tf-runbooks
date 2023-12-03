# resource group
output "resource_group" {
  value = azurerm_resource_group.this
}
# automation account
output "automation_account" {
  value = azurerm_automation_account.this
}