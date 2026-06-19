# terraform-azure-mcaf-monitoring
Terraform Module to Enable Azure Monitoring

The module default for storage account replication type defaults to GRS because [archive tiering is not supported by ZRS](https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview#summary-of-access-tier-options).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4, < 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | github.com/schubergphilis/terraform-azure-mcaf-key-vault | v1.0.1 |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | github.com/schubergphilis/terraform-azure-mcaf-storage-account.git | v0.8.4 |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_data_export_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_data_export_rule) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Location of the Storage account | `string` | n/a | yes |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | n/a | <pre>object({<br/>    name                            = string<br/>    allow_resource_only_permissions = optional(bool, false)<br/>    sku                             = optional(string, "PerGB2018")<br/>    retention_in_days               = optional(number, 30)<br/>    tags                            = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the resources. | `string` | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Create a new Key Vault for CMK. You can also use an existing Key Vault by setting the `cmk_key_vault_id` in the `storage_account` variable.<br/><br/>    The following arguments are supported:<br/><br/>    - `name` - (Optional) The name of the Key Vault. Defaults to null.<br/>    - `cmk_expiration_date` - (Optional) The expiration date of the customer-managed key. Defaults to null. | <pre>object({<br/>    name                = optional(string)<br/>    cmk_expiration_date = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account) | Configure an optional storage account for long term storage of logs<br/><br/>    The following arguments are supported:<br/><br/>    - `name` - (Required) The name of the storage account.<br/>    - `account_tier` - (Optional) The tier of the storage account. Defaults to `Standard`.<br/>    - `account_replication_type` - (Optional) The replication type for the storage account. Defaults to `GRS` (Geo-Redundant Storage) because archive tier only supports LRS, GRS and RAGRS.<br/>    - `access_tier` - (Optional) The access tier for blobs in the storage account. Defaults to `Cool`.<br/>    - `infrastructure_encryption_enabled` - (Optional) Specifies whether infrastructure encryption is enabled. Defaults to true.<br/>    - `cmk_key_vault_id` - (Optional) The ID of the Key Vault containing the customer-managed key. Defaults to null.<br/>    - `cmk_key_name` - (Optional) The name of the customer-managed key in the Key Vault. Defaults to null.<br/>    - `system_assigned_identity_enabled` - (Optional) Whether a system-assigned identity is enabled. Defaults to false.<br/>    - `user_assigned_identities` - (Optional) A set of user-assigned identities.<br/>    - `immutability_policy` - (Optional) Immutability policy configuration. If undefined will not create a Immutability Policy<br/>      - `state` - (Optional) The state of the immutability policy. Defaults to `Unlocked`.<br/>      - `allow_protected_append_writes` - (Optional) Whether protected append writes are allowed. Defaults to true.<br/>      - `period_since_creation_in_days` - (Optional) The immutability period in days. Defaults to 14 days.<br/>    - `storage_management_policy` - (Optional) storage management policy and retention settings configuration, if all move\_to\_* or delete\_after\_days inputs are null does not create a storage management policy.<br/>      - `blob_delete_retention_days` - (Optional) Retention days for blob deletion. Defaults to 90 days.<br/>      - `container_delete_retention_days` - (Optional) Retention days for container deletion. Defaults to 90 days.<br/>      - `move_to_cool_after_days` - (Optional) Days to wait before moving data to the cool tier. Defaults to null.<br/>      - `move_to_cold_after_days` - (Optional) Days to wait before moving data to the cold tier. Defaults to null.<br/>      - `move_to_archive_after_days` - (Optional) Days to wait before moving data to the archive tier. Defaults to null.<br/>      - `delete_after_days` - (Optional) Days after which data should be deleted. Defaults to null.<br/>    - `network_configuration` - (Optional) Network Configuration, if undefined will only allow private connections.<br/>      - `https_traffic_only_enabled` - (Optional) Allow only HTTPS traffic. Defaults to true.<br/>      - `allow_nested_items_to_be_public` - (Optional) If nested items can be public. Defaults to false.<br/>      - `public_network_access_enabled` - (Optional) Enables public network access. Defaults to false.<br/>      - `default_action` - (Optional) Default action for network rules when none are matched. Defaults to `Deny`.<br/>      - `virtual_network_subnet_ids` - (Optional) A set of virtual network subnet IDs.<br/>      - `ip_rules` - (Optional) A set of IP rules for accessing the storage account.<br/>      - `bypass` - (Optional) Specifies which services bypass network rules. Defaults to ["AzureServices"].<br/>    - `tags` - (Optional) A map of tags to assign to the storage account. | <pre>object({<br/>    name                              = string<br/>    account_tier                      = optional(string, "Standard")<br/>    account_replication_type          = optional(string, "GRS")<br/>    access_tier                       = optional(string, "Cool")<br/>    infrastructure_encryption_enabled = optional(bool, true)<br/>    cmk_key_vault_id                  = optional(string, null)<br/>    cmk_key_name                      = optional(string, "cmkrsa")<br/>    system_assigned_identity_enabled  = optional(bool, true)<br/>    user_assigned_identities          = optional(set(string), [])<br/>    immutability_policy = optional(object({<br/>      state                         = optional(string, "Unlocked")<br/>      allow_protected_append_writes = optional(bool, true)<br/>      period_since_creation_in_days = optional(number, 14)<br/>    }), null)<br/>    storage_management_policy = optional(object({<br/>      blob_delete_retention_days      = optional(number, 90)<br/>      container_delete_retention_days = optional(number, 90)<br/>      move_to_cool_after_days         = optional(number, null)<br/>      move_to_cold_after_days         = optional(number, null)<br/>      move_to_archive_after_days      = optional(number, null)<br/>      delete_after_days               = optional(number, null)<br/>    }), {})<br/>    network_configuration = optional(object({<br/>      https_traffic_only_enabled      = optional(bool, true)<br/>      allow_nested_items_to_be_public = optional(bool, false)<br/>      public_network_access_enabled   = optional(bool, false)<br/>      default_action                  = optional(string, "Deny")<br/>      virtual_network_subnet_ids      = optional(set(string), [])<br/>      ip_rules                        = optional(set(string), [])<br/>      bypass                          = optional(set(string), ["AzureServices"])<br/>    }), {})<br/>    tags = optional(map(string), {})<br/>  })</pre> | `null` | no |
| <a name="input_table_names_to_export"></a> [table\_names\_to\_export](#input\_table\_names\_to\_export) | List of table names to export to the storage account. This will deploy a Log Analytics Data Export Rule. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The tenant ID of the Azure subscription. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace created by the module |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the Resource Group created by the module |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | n/a |
<!-- END_TF_DOCS -->