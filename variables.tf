variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the resources."
}

variable "location" {
  type        = string
  description = "Location of the Storage account"
}

variable "log_analytics_workspace" {
  type = object({
    name                            = string
    allow_resource_only_permissions = optional(bool, false)
    sku                             = optional(string, "PerGB2018")
    retention_in_days               = optional(number, 30)
    tags                            = optional(map(string), {})
  })
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID of the Azure subscription."
  default     = null
}

variable "key_vault" {
  type = object({
    name                = optional(string)
    cmk_expiration_date = optional(string)
  })
  description = <<DESCRIPTION
    Create a new Key Vault for CMK. You can also use an existing Key Vault by setting the `cmk_key_vault_id` in the `storage_account` variable.

    The following arguments are supported:
    
    - `name` - (Optional) The name of the Key Vault. Defaults to null.
    - `cmk_expiration_date` - (Optional) The expiration date of the customer-managed key. Defaults to null.
  DESCRIPTION
  default     = null
}

variable "storage_account" {
  type = object({
    name                              = string
    account_tier                      = optional(string, "Standard")
    account_replication_type          = optional(string, "GRS")
    access_tier                       = optional(string, "Cool")
    infrastructure_encryption_enabled = optional(bool, true)
    cmk_key_vault_id                  = optional(string, null)
    cmk_key_name                      = optional(string, "cmkrsa")
    system_assigned_identity_enabled  = optional(bool, true)
    user_assigned_identities          = optional(set(string), [])
    immutability_policy = optional(object({
      state                         = optional(string, "Unlocked")
      allow_protected_append_writes = optional(bool, true)
      period_since_creation_in_days = optional(number, 14)
    }), null)
    storage_management_policy = optional(object({
      blob_delete_retention_days      = optional(number, 90)
      container_delete_retention_days = optional(number, 90)
      move_to_cool_after_days         = optional(number, null)
      move_to_cold_after_days         = optional(number, null)
      move_to_archive_after_days      = optional(number, null)
      delete_after_days               = optional(number, null)
    }), {})
    network_configuration = optional(object({
      https_traffic_only_enabled      = optional(bool, true)
      allow_nested_items_to_be_public = optional(bool, false)
      public_network_access_enabled   = optional(bool, false)
      default_action                  = optional(string, "Deny")
      virtual_network_subnet_ids      = optional(set(string), [])
      ip_rules                        = optional(set(string), [])
      bypass                          = optional(set(string), ["AzureServices"])
    }), {})
    tags = optional(map(string), {})
  })
  description = <<DESCRIPTION
    Configure an optional storage account for long term storage of logs

    The following arguments are supported:
    
    - `name` - (Required) The name of the storage account.
    - `account_tier` - (Optional) The tier of the storage account. Defaults to `Standard`.
    - `account_replication_type` - (Optional) The replication type for the storage account. Defaults to `GRS` (Geo-Redundant Storage) because archive tier only supports LRS, GRS and RAGRS.
    - `access_tier` - (Optional) The access tier for blobs in the storage account. Defaults to `Cool`.
    - `infrastructure_encryption_enabled` - (Optional) Specifies whether infrastructure encryption is enabled. Defaults to true.
    - `cmk_key_vault_id` - (Optional) The ID of the Key Vault containing the customer-managed key. Defaults to null.
    - `cmk_key_name` - (Optional) The name of the customer-managed key in the Key Vault. Defaults to null.
    - `system_assigned_identity_enabled` - (Optional) Whether a system-assigned identity is enabled. Defaults to false.
    - `user_assigned_identities` - (Optional) A set of user-assigned identities.
    - `immutability_policy` - (Optional) Immutability policy configuration. If undefined will not create a Immutability Policy
      - `state` - (Optional) The state of the immutability policy. Defaults to `Unlocked`.
      - `allow_protected_append_writes` - (Optional) Whether protected append writes are allowed. Defaults to true.
      - `period_since_creation_in_days` - (Optional) The immutability period in days. Defaults to 14 days.
    - `storage_management_policy` - (Optional) storage management policy and retention settings configuration, if all move_to_* or delete_after_days inputs are null does not create a storage management policy.
      - `blob_delete_retention_days` - (Optional) Retention days for blob deletion. Defaults to 90 days.
      - `container_delete_retention_days` - (Optional) Retention days for container deletion. Defaults to 90 days.
      - `move_to_cool_after_days` - (Optional) Days to wait before moving data to the cool tier. Defaults to null.
      - `move_to_cold_after_days` - (Optional) Days to wait before moving data to the cold tier. Defaults to null.
      - `move_to_archive_after_days` - (Optional) Days to wait before moving data to the archive tier. Defaults to null.
      - `delete_after_days` - (Optional) Days after which data should be deleted. Defaults to null.
    - `network_configuration` - (Optional) Network Configuration, if undefined will only allow private connections.
      - `https_traffic_only_enabled` - (Optional) Allow only HTTPS traffic. Defaults to true.
      - `allow_nested_items_to_be_public` - (Optional) If nested items can be public. Defaults to false.
      - `public_network_access_enabled` - (Optional) Enables public network access. Defaults to false.
      - `default_action` - (Optional) Default action for network rules when none are matched. Defaults to `Deny`.
      - `virtual_network_subnet_ids` - (Optional) A set of virtual network subnet IDs.
      - `ip_rules` - (Optional) A set of IP rules for accessing the storage account.
      - `bypass` - (Optional) Specifies which services bypass network rules. Defaults to ["AzureServices"].
    - `tags` - (Optional) A map of tags to assign to the storage account.
  DESCRIPTION

  default = null
}

variable "table_names_to_export" {
  type        = list(string)
  description = "List of table names to export to the storage account. This will deploy a Log Analytics Data Export Rule."
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
} 