# azurecaf 4.0 has no native API Center resource definitions. The resource-group
# definition has compatible 1..90 alphanumeric/hyphen naming constraints and the
# slug is deliberately disabled so no unrelated "rg" abbreviation is emitted.
resource "azurecaf_name" "service" {
  count = local.create_service ? 1 : 0

  name          = var.settings.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "workspaces" {
  for_each = local.workspaces

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "environments" {
  for_each = local.environments

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "apis" {
  for_each = local.apis

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "api_versions" {
  for_each = local.api_versions

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "definitions" {
  for_each = local.definitions

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "deployments" {
  for_each = local.deployments

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}

resource "azurecaf_name" "metadata_schemas" {
  for_each = local.metadata_schemas

  name          = each.value.name
  resource_type = "azurerm_resource_group"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = try(var.global_settings.clean_input, true)
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = false
}
