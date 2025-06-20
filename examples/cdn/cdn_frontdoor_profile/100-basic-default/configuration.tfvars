resource_groups = {
  caf_frontdoor_rg = {
    name     = "caf-frontdoor-rg"
    location = "westeurope"
  }
}

cdn_frontdoor_profiles = {
  basic = {
    name               = "caf-frontdoor-basic"
    location           = "westeurope"
    resource_group_key = "caf_frontdoor_rg"
    sku_name           = "Standard_AzureFrontDoor"
    # Puedes añadir más atributos según el módulo
  }
}
