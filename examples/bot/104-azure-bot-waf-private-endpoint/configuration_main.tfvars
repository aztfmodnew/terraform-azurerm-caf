global_settings = {
  default_region = "region1"
  inherit_tags   = true
  regions = {
    region1 = "westeurope"
  }
  prefixes = ["caf"]
  use_slug = true
}

tags = {
  example      = "azure-bot-waf-private-endpoint"
  landingzone  = "examples"
  architecture = "secure-bot"
  cost_center  = "it-security"
}
