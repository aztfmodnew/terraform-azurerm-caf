global_settings = {
  default_region = "region1"
  random_length  = 5
  regions = {
    region1 = "australiaeast"
    # region2 = "australiacentral"            # Optional - Add additional regions
  }
}
resource_groups = {
  nsp_re1 = {
    name   = "nsp_re1"
    region = "region1"
  }
}

network_security_perimeters = {
  nsp1_re1 = {
    location           = "australiaeast"
    resource_group_key = "nsp_re1"
    name               = "nsp1"
    tags = {
      environment = "dev"
    }
  }
}
