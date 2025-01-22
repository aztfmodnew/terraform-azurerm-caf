#resource "azurecaf_name" "nsp" {
#  name          = var.settings.name
#  resource_type = "azurerm_network_security_perimeter"
#  prefixes      = var.global_settings.prefixes
#  random_length = var.global_settings.random_length
#  clean_input   = true
#  passthrough   = var.global_settings.passthrough
#  use_slug      = var.global_settings.use_slug
#}