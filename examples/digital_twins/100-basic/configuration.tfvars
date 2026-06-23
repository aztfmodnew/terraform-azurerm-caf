global_settings = {
  default_region = "region1"
  regions = {
    region1 = "southeastasia"
  }
  random_length = 5
}

resource_groups = {
  rg1 = {
    name   = "example-adt"
    region = "region1"
  }
}

managed_identities = {
  dtmi = {
    name               = "dt-basic-mi"
    resource_group_key = "rg1"
  }
}

digital_twins_instances = {
  adt1 = {
    name               = "example-adt"
    region             = "region1"
    resource_group_key = "rg1"
    identity = {
      type                  = "UserAssigned"
      managed_identity_keys = ["dtmi"]
    }
  }
}