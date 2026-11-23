# resourceDefinition.json has no standalone-gateway entry. The supported APIM
# service rule is a conservative compatible subset (alphanumeric/dash, <=50).
# Generate with the established APIM rule, then compact to the standalone
# gateway provider limit while retaining a configured random suffix.
resource "azurecaf_name" "generated" {
  name          = var.settings.name
  resource_type = "azurerm_api_management"
  prefixes      = try(var.global_settings.prefixes, null)
  suffixes      = try(var.global_settings.suffixes, null)
  random_length = try(var.global_settings.random_length, 0)
  clean_input   = true
  passthrough   = try(var.global_settings.passthrough, false)
  use_slug      = try(var.global_settings.use_slug, true)
}

locals {
  standalone_gateway_random_length = max(0, try(var.global_settings.random_length, 0))
  standalone_gateway_suffix_length = min(
    45,
    local.standalone_gateway_random_length > 0 ? local.standalone_gateway_random_length + 1 : 0
  )
  standalone_gateway_name = length(azurecaf_name.generated.result) <= 45 ? azurecaf_name.generated.result : format(
    "%s%s",
    substr(azurecaf_name.generated.result, 0, 45 - local.standalone_gateway_suffix_length),
    substr(
      azurecaf_name.generated.result,
      length(azurecaf_name.generated.result) - local.standalone_gateway_suffix_length,
      local.standalone_gateway_suffix_length
    )
  )
}

resource "azurecaf_name" "resource" {
  name          = local.standalone_gateway_name
  resource_type = "azurerm_api_management"
  clean_input   = false
  passthrough   = true
  use_slug      = false
}
