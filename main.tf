resource "azurerm_log_analytics_workspace" "this" {
  name                            = var.log_analytics_workspace.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  allow_resource_only_permissions = var.log_analytics_workspace.allow_resource_only_permissions
  sku                             = var.log_analytics_workspace.sku
  retention_in_days               = var.log_analytics_workspace.retention_in_days
  tags = merge(
    try(var.tags),
    try(var.log_analytics_workspace.tags),
    tomap({
      "Resource Type" = "Log Analytics Workspace"
    })
  )
}

resource "azurerm_user_assigned_identity" "storage_account_mid" {
  count               = var.storage_account != null ? 1 : 0
  name                = var.storage_account.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "storage_account_key_vault_crypto_user" {
  count                            = var.storage_account != null ? 1 : 0
  principal_id                     = azurerm_user_assigned_identity.storage_account_mid[0].principal_id
  scope                            = var.storage_account.cmk_key_vault_key_resource_versionless_id
  role_definition_name             = "Key Vault Crypto Service Encryption User"
  skip_service_principal_aad_check = false
}

module "storage_account" {
  count   = var.storage_account != null ? 1 : 0
  source  = "schubergphilis-ep/mcaf-storage-account/azure"
  version = "3.0.0"

  name                              = var.storage_account.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  account_tier                      = var.storage_account.account_tier
  account_replication_type          = var.storage_account.account_replication_type
  account_kind                      = "StorageV2"
  access_tier                       = var.storage_account.access_tier
  infrastructure_encryption_enabled = var.storage_account.infrastructure_encryption_enabled
  enable_cmk_encryption             = true
  cmk_key                           = { key_vault_key_id = var.storage_account.cmk_key_vault_key_id }
  system_assigned_identity_enabled  = false
  user_assigned_identities          = [azurerm_user_assigned_identity.storage_account_mid[0].id] // Note: The first identity is also always used for key vault access
  immutability_policy = {
    state                         = "Unlocked"
    allow_protected_append_writes = true
    period_since_creation_in_days = var.storage_account.storage_management_policy.delete_after_days
  }
  network_configuration     = var.storage_account.network_configuration

  change_feed_enabled = false

  versioning_enabled = true


  tags = merge(
    var.tags,
    var.storage_account.tags
  )

  depends_on = [azurerm_role_assignment.storage_account_key_vault_crypto_user]
}

resource "azurerm_storage_container" "container" {
  for_each              = var.storage_account.containers
  name                  = each.key
  storage_account_id    = module.storage_account[0].id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "storage_account" {
  storage_account_id = module.storage_account[0].id
  rule {
    name    = "Default storage management policy"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = var.storage_account.storage_management_policy.move_to_cool_after_days
        tier_to_cold_after_days_since_creation_greater_than     = var.storage_account.storage_management_policy.move_to_cold_after_days
        tier_to_archive_after_days_since_creation_greater_than  = var.storage_account.storage_management_policy.move_to_archive_after_days
        delete_after_days_since_modification_greater_than       = var.storage_account.storage_management_policy.delete_after_days
      }
    }
  }

  dynamic "rule" {
    for_each = azurerm_storage_container.container
    content {
      name    = "Storage management policy for ${rule.value.name}"
      enabled = true
      filters {
        blob_types   = ["blockBlob"]
        prefix_match = ["${rule.value.name}/"]
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than = var.storage_account.containers[rule.key].storage_management_policy.move_to_cool_after_days
          tier_to_cold_after_days_since_creation_greater_than     = var.storage_account.containers[rule.key].storage_management_policy.move_to_cold_after_days
          tier_to_archive_after_days_since_creation_greater_than  = var.storage_account.containers[rule.key].storage_management_policy.move_to_archive_after_days
          delete_after_days_since_modification_greater_than       = var.storage_account.containers[rule.key].storage_management_policy.delete_after_days
        }
      }
    }
  }
}

resource "azurerm_storage_container_immutability_policy" "containers" {
  for_each                              = azurerm_storage_container.container
  immutability_period_in_days           = var.storage_account.containers[each.key].storage_management_policy.delete_after_days
  storage_container_resource_manager_id = each.value.resource_manager_id
  protected_append_writes_enabled       = true # Specifically not `protected_append_writes_all_enabled` to ensure this is only set for AppendBlobs
}

resource "azurerm_log_analytics_data_export_rule" "this" {
  count = var.table_names_to_export != null ? 1 : 0

  name                    = "Export-To-Storage"
  resource_group_name     = var.resource_group_name
  workspace_resource_id   = azurerm_log_analytics_workspace.this.id
  destination_resource_id = module.storage_account[0].id
  table_names             = var.table_names_to_export
  enabled                 = true
}
