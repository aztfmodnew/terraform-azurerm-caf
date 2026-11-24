output "diagnostic_settings" {
  description = "Diagnostic settings created for the target resource, keyed by profile."
  value       = azurerm_monitor_diagnostic_setting.diagnostics
}
