output "storage_account_id" {
  value = length(module.storage_account) > 0 ? module.storage_account[0].id : null
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace created by the module"
  value       = azurerm_log_analytics_workspace.this.id
}

output "eventhub_namespace_id" {
  value = length(module.eventhub_namespace) > 0 ? module.eventhub_namespace[0].eventhub_namespace_id : null
}

output "eventhub_namespace_name" {
  value = length(module.eventhub_namespace) > 0 ? module.eventhub_namespace[0].eventhub_namespace_name : null
}

output "eventhub_id" {
  value = length(module.eventhub_namespace) > 0 ? values(module.eventhub_namespace[0].event_hubs)[0].id : null
}

output "eventhub_name" {
  value = length(module.eventhub_namespace) > 0 ? values(module.eventhub_namespace[0].event_hubs)[0].name : null
}
