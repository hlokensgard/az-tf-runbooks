variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
  default     = "westeurope"
}

variable "subscription_id" {
  description = "The subscription id for the automation account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group that will contain the automation account. Will creat a new one."
  type        = string
}

variable "automation_account_name" {
  description = "The name of the automation account."
  type        = string
}

variable "runbook_name" {
  description = "The name of the runbook. This is not the path but the display name in the portal."
  type        = string
}

variable "powershell_version" {
  description = "The version of powershell to use for the automation account. Support 5.1 and 7.2"
  type        = string
  default     = "7.2"
  validation {
    condition     = can(regex("^(5.1|7.2)$", var.powershell_version))
    error_message = "powershell_version must be 5.1 or 7.2"
  }
}

variable "powershell_modules" {
  description = "The powershell modules to install on the automation account."
  type = object({
    prerequisites = optional(list(object({
      name    = string
      uri     = string
      version = string
    })), [])
    modules = optional(list(object({
      name    = string
      uri     = string
      version = string
    })), [])
  })
  default = {
    prerequisites = []
    modules       = []
  }
}

variable "tags" {
  description = "Tags to be applied to all resources in this example."
  type        = map(string)
  default     = {}
}

variable "runbook_file_path" {
  description = "The path to the runbook file to be uploaded to the storage account."
  type        = string
  default     = ""
}
