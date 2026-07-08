terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4"
    }
  }
}

provider "azurerm" {
  subscription_id = "00000000-0000-0000-0000-000000000000"
  features {}
}

module "without_storage_account" {
  source = "../.."

  resource_group_name = "example-resource-group"

  log_analytics_workspace = {
    name = "example-log-analytics-workspace"
  }

  location = "West Europe"
  tags     = {}
}

module "with_storage_account" {
  source = "../.."

  resource_group_name = "example-resource-group"

  log_analytics_workspace = {
    name = "example-log-analytics-workspace2"
  }

  storage_account = {
    name                     = "examplestorageaccount"
    access_tier              = "Cool"
    account_replication_type = "ZRS"
    cmk_key_vault_id         = "Resource ID of the Key Vault"
    log_retention_days       = 1095 # 3 Years
    snapshot_retention_days  = 90
  }

  table_names_to_export = ["AzureActivity"]

  location = "West Europe"
  tags     = {}
}