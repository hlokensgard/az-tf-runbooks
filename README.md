# az-tf-runbooks
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~>1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~>1.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.automation_account_modules](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.automation_account_pre_req_modules](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.runbook](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.runbook_ps7_moduels](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_automation_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_automation_job_schedule.one_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_schedule.one_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_automation_variable_string.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_variable_string) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aa_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.runbooks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.modules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_blob.runbooks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.runbooks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [random_string.sa_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_storage_account_blob_container_sas.runbooks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_blob_container_sas) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | The name of the automation account. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group that will contain the automation account. Will creat a new one. | `string` | n/a | yes |
| <a name="input_runbook_name"></a> [runbook\_name](#input\_runbook\_name) | The name of the runbook. This is not the path but the display name in the portal. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription id for the automation account | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region in which all resources in this example should be created. | `string` | `"westeurope"` | no |
| <a name="input_powershell_modules"></a> [powershell\_modules](#input\_powershell\_modules) | The powershell modules to install on the automation account. | <pre>object({<br>    prerequisites = optional(list(object({<br>      name    = string<br>      uri     = string<br>      version = string<br>    })), [])<br>    modules = optional(list(object({<br>      name    = string<br>      uri     = string<br>      version = string<br>    })), [])<br>  })</pre> | <pre>{<br>  "modules": [],<br>  "prerequisites": []<br>}</pre> | no |
| <a name="input_powershell_version"></a> [powershell\_version](#input\_powershell\_version) | The version of powershell to use for the automation account. Support 5.1 and 7.2 | `string` | `"7.2"` | no |
| <a name="input_runbook_file_path"></a> [runbook\_file\_path](#input\_runbook\_file\_path) | The path to the runbook file to be uploaded to the storage account. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources in this example. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automation_account"></a> [automation\_account](#output\_automation\_account) | automation account |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | resource group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->