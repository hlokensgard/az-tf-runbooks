module "runbook" {
  source                  = "../"
  subscription_id         = var.subscription_id
  location                = "westeurope"
  resource_group_name     = "runbook-example"
  automation_account_name = "runbook-example"
  runbook_name            = "runbook-example"
  powershell_version      = "7.2"
  powershell_modules = {
    "prerequisites" = [
      {
        "name"    = "Microsoft.Graph.Authentication"
        "uri"     = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Authentication/"
        "version" = "2.10.0"
      },
      {
        "name"    = "Az.Accounts"
        "uri"     = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/"
        "version" = "2.13.0"
      }
    ]
    modules = [
      {
        "name"    = "Microsoft.Graph.Groups"
        "uri"     = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Groups/"
        "version" = "2.10.0"
      },
      {
        "name"    = "Microsoft.Graph.Users"
        "uri"     = "https://www.powershellgallery.com/api/v2/package/Microsoft.Graph.Users/"
        "version" = "2.10.0"
      }
    ]
  }
  runbook_file_path = "hello-world.ps1"
}
