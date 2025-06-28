resource_groups = {
  cdn_rg = {
    name     = "rg-cdn-frontdoor-example"
    location = "West Europe"
    
    tags = {
      environment = "example"
      purpose     = "cdn-frontdoor"
    }
  }
}
