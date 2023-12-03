locals {
  valid_powershell_version = {
    "5.1" = "PowerShell51"
    "7.2" = "PowerShell72"
  }

  current_powershell_version = local.valid_powershell_version[var.powershell_version]

  prerequisites_modules = {
    for module in var.powershell_modules.prerequisites :
    module.uri => {
      name    = module.name
      uri     = module.uri
      version = module.version
    }
    if var.powershell_modules["prerequisites"] != [] || var.powershell_modules != {}
  }
  modules = {
    for module in var.powershell_modules.modules :
    module.uri => {
      name    = module.name
      uri     = module.uri
      version = module.version
    }
    if var.powershell_modules["modules"] != [] || var.powershell_modules != {}
  }
}
