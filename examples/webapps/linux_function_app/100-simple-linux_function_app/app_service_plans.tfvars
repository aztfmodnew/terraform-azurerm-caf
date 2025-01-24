app_service_plans = {
  asp1 = {
    resource_group_key = "test_re1"
    name               = "asp-simple"
    kind               = "linux"
    reserved           = true

    sku = {
      tier = "Standard"
      size = "S1"
    }
    tags = {
      project = "Test"
    }
  }
}