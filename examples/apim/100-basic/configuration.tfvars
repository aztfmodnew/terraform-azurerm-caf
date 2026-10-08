global_settings = {
  default_region = "region1"
  random_length  = 5
  regions = {
    region1 = "australiaeast"
  }
  inherit_tags = true
  tags = {
    example = "apim/100-basic"
  }
}

resource_groups = {
  rg1 = {
    name   = "example-agw"
    region = "region1"
  }
}


api_management = {
  apim1 = {
    name   = "example-apim"
    region = "region1"
    resource_group = {
      key = "rg1"
    }
    publisher_name  = "My Company"
    publisher_email = "company@terraform.io"

    sku_name = "Developer_1"
    protocols = {
      enable_http2 = true
    }
    security = {
      enable_backend_ssl30  = false
      enable_backend_tls10  = false
      enable_backend_tls11  = false
      enable_frontend_ssl30 = false
      enable_frontend_tls10 = false
      enable_frontend_tls11 = false
    }
    tags = {
      project = "demo"
    }
  }
}