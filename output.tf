output "sqlmi_name" {
  description = "The Name of the sql managed instance"
  value       = azurerm_mssql_managed_instance.this_sqlmi.name
}

output "sqlmi_id" {
  description = "sql managed instance id"
  value       = azurerm_mssql_managed_instance.this_sqlmi.id
}

output "sqlmi_system_identity" {
  description = "sql managed instance system assigned identity"
  value       = azurerm_mssql_managed_instance.this_sqlmi.identity.0.principal_id
}