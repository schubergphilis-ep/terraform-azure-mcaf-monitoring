resource "azurerm_user_assigned_identity" "eventhub_namespace_mid" {
  count               = var.event_hub_namespace != null ? 1 : 0
  name                = var.event_hub_namespace.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "eventhub_namespace" {
  source = "github.com/schubergphilis/terraform-azure-mcaf-eventhub.git?ref=feat-deploy-hubs-support-cmk"
  count        = var.event_hub_namespace != null ? 1 : 0

  eventhub_namespace_name     = var.event_hub_namespace.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  eventhub_namespace_sku      = var.event_hub_namespace.sku
  eventhub_namespace_capacity = var.event_hub_namespace.capacity

  eventhub_namespace_user_assigned_identity_ids = [azurerm_user_assigned_identity.eventhub_namespace_mid[0].id]

  eventhub_namespace_customer_managed_key = var.event_hub_namespace.customer_managed_key != null ? {
    user_assigned_identity_id         = azurerm_user_assigned_identity.eventhub_namespace_mid[0].id
    key_vault_id                      = var.event_hub_namespace.customer_managed_key.key_vault_id
    key_name                          = var.event_hub_namespace.customer_managed_key.key_name
    infrastructure_encryption_enabled = true
  } : null
  eventhub_namespace_network_ruleset = {
    public_network_access_enabled  = false
    trusted_service_access_enabled = true
  }
  event_hubs = {
    (var.event_hub_namespace.hub_name) = {
      partition_count   = 4
      message_retention = 7
      authorization_rules = merge(
        {
          "diagnostics-settings-policy" = {
            listen = false
            send   = true
            manage = false
          }
        },
        var.event_hub_namespace.hub_authorization_rules
      )
      consumer_groups = var.event_hub_namespace.hub_consumer_groups
    }
  }
  tags = merge(
    var.tags,
    var.event_hub_namespace.tags
  )
}

data "azuread_service_principal" "windows_azure_security_resource_provider" {
  count        = var.event_hub_namespace != null ? 1 : 0
  display_name = "Windows Azure Security Resource Provider"
}

resource "azurerm_role_assignment" "security_provider" {
  count                = var.event_hub_namespace != null ? 1 : 0
  principal_id         = data.azuread_service_principal.windows_azure_security_resource_provider[0].object_id
  scope                = module.eventhub_namespace[0].event_hubs[var.event_hub_namespace.hub_name].id
  role_definition_name = "Azure Event Hubs Data Sender"
}

resource "azurerm_role_assignment" "this" {
  count                = var.event_hub_namespace != null ? 1 : 0
  principal_id         = var.resource_owner_object_id
  scope                = module.eventhub_namespace[0].event_hubs[var.event_hub_namespace.hub_name].id
  role_definition_name = "Azure Event Hubs Data Owner"
}
