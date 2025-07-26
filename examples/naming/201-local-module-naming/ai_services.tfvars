# AI Services configuration for local module naming example

ai_services = {
  main = {
    name               = "main-ai"
    resource_group_key = "staging"

    kind     = "AIServices"
    sku_name = "S0"

    tags = {
      purpose = "demo"
      example = "local-module-naming"
    }
  }
}
