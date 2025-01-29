# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
service_plans = {
  sp1 = {
    resource_group_key = "test_re1"
    name               = "asp-simple"
    os_type            = "Linux"
    sku_name           = "FC1"


    tags = {
      project = "Test"
    }
  }
}