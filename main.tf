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
  scope                            = var.storage_account.cmk_key_vault_id
  role_definition_name             = "Key Vault Crypto Service Encryption User"
  skip_service_principal_aad_check = false
}

module "storage_account" {
  source  = "schubergphilis-ep/mcaf-storage-account/azure"
  version = "0.11.0"
  count  = var.storage_account != null ? 1 : 0

  name                              = var.storage_account.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  account_tier                      = var.storage_account.account_tier
  account_replication_type          = var.storage_account.account_replication_type
  account_kind                      = "StorageV2"
  access_tier                       = var.storage_account.access_tier
  infrastructure_encryption_enabled = var.storage_account.infrastructure_encryption_enabled
  enable_cmk_encryption             = true
  cmk_key_vault_id                  = var.storage_account.cmk_key_vault_id
  cmk_key_name                      = var.storage_account.cmk_key_name
  system_assigned_identity_enabled  = var.storage_account.system_assigned_identity_enabled
  user_assigned_identities          = [azurerm_user_assigned_identity.storage_account_mid[0].id] // Note: The first identity is also always used for key vault access
  immutability_policy               = var.storage_account.immutability_policy
  network_configuration             = var.storage_account.network_configuration
  storage_management_policy         = var.storage_account.storage_management_policy
  tags = merge(
    var.tags,
    var.storage_account.tags
  )

  depends_on = [azurerm_role_assignment.storage_account_key_vault_crypto_user]
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
