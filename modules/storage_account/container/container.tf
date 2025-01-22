# Tested with :  AzureRM version 2.61.0
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container

# trunk-ignore(tflint/terraform_required_providers)
resource "azurerm_storage_container" "stg" {
  name                              = var.settings.name
  storage_account_id                = var.storage_account_id
  container_access_type             = try(var.settings.container_access_type, "private")
  default_encryption_scope          = try(var.settings.default_encryption_scope, null)
  encryption_scope_override_enabled = try(var.settings.encryption_scope_override_enabled, null)
  metadata                          = try(var.settings.metadata, null)
}