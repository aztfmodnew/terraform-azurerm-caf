global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westus"
  }
  random_length = 5
  #pass_through = true
}

resource_groups = {
  test-rg = {
    name = "rg-alz-caf-test-1"
  }
}

ai_services = {
  ai_service1 = {
    resource_group_key = "test-rg"
    sku = "F0"   
    location = "region1"
    tags = {
      environment = "test"
    }
  }
  }
