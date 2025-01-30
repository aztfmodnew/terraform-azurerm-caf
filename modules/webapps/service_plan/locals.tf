locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags,
    null)
  )
  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = coalesce(var.resource_group.name)

}
/*
sku_name - (Required) The SKU for the plan. Possible values include B1, B2, B3, D1, F1, I1, I2, I3, I1v2, I2v2, I3v2, I4v2, I5v2, I6v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, EP1, EP2, EP3, FC1, WS1, WS2, WS3, and Y1.
  # skus = {
  #   "B1" = "Basic"
  #   "B2" = "Basic"
  #   "B3" = "Basic"
  #   "D1" = "Shared"
  #   "F1" = "Free"
  #   "I1" = "Isolated"
  #   "I2" = "Isolated"
  #   "I3" = "Isolated"
  #   "I1v2" = "Isolated"
  #   "I2v2" = "Isolated"
  #   "I3v2" = "Isolated"
  #   "I4v2" = "Isolated"
  #   "I5v2" = "Isolated"
  #   "I6v2" = "Isolated"
  #   "P1v2" = "PremiumV2"
  #   "P2v2" = "PremiumV2"
  #   "P3v2" = "PremiumV2"
  #   "P0v3" = "PremiumV3"
  #   "P1v3" = "PremiumV3"
  #   "P2v3" = "PremiumV3"
  #   "P3v3" = "PremiumV3"
  #   "P1mv3" = "PremiumMV3
  #   "P2mv3" = "PremiumMV3"
  #   "P3mv3" = "PremiumMV3"
  #   "P4mv3" = "PremiumMV3"
  #   "P5mv3" = "PremiumMV3"
  #   "S1" = "Standard"
  #   "S2" = "Standard"
  #   "S3" = "Standard"
  #   "SHARED" = "Shared"
  #   "EP1" = "ElasticPremium"
  #   "EP2" = "ElasticPremium"
  #   "EP3" = "ElasticPremium"
  #   "FC1" = "Flex Consumption"
  #   "WS1" = "WindowsServer"
  #   "WS2" = "WindowsServer"
  #   "WS3" = "WindowsServer"
  #   "Y1" = "Consumption"

}
*/