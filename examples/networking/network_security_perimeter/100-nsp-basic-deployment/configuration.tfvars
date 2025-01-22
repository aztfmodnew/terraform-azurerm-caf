global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast" # You can adjust the Azure Region you want to use to deploy NAT Gateway
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

