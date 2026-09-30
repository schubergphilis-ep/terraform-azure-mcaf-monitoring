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

  location                 = "West Europe"
  tags                     = {}
  resource_owner_object_id = "00000000-0000-0000-0000-000000000000"
}

module "with_storage_account" {
  source = "../.."

  resource_group_name = "example-resource-group"

  log_analytics_workspace = {
    name = "example-log-analytics-workspace2"
  }

  storage_account = {
    name                                      = "examplestorageaccount"
    access_tier                               = "Cool"
    account_replication_type                  = "ZRS"
    cmk_key_vault_key_id                      = "Resource ID of the Key Vault"
    cmk_key_vault_key_resource_versionless_id = "Versionless id of the CMK key"

    storage_management_policy = {
      blob_delete_retention_days      = 90
      container_delete_retention_days = 90
      move_to_cool_after_days         = 15
      move_to_cold_after_days         = 30
      move_to_archive_after_days      = 360
      delete_after_days               = 1095 # 3 Years
    }
  }

  table_names_to_export = ["AzureActivity"]

  location                 = "West Europe"
  tags                     = {}
  resource_owner_object_id = "00000000-0000-0000-0000-000000000000"
}
