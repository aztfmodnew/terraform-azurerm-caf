resource "time_sleep" "delay_create" {
  depends_on = [azurerm_recovery_services_vault.asr]

  create_duration = "60s"
}