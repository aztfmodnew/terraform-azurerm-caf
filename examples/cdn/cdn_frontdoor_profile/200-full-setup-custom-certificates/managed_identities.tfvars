managed_identities = {
  cdn_identity = {
    name               = "cdn-frontdoor-identity"
    resource_group_key = "cdn_rg"

    tags = {
      purpose = "cdn-frontdoor"
    }
  }
}
