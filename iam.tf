resource "azurerm_role_assignment" "aa_contributor" {
  scope                = azurerm_automation_account.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.this.identity[0].principal_id
}
