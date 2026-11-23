global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "policy-fragment", region = "primary" }
}
api_management = {
  gateway = {
    name           = "policy-fragment", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}

api_management_policy_fragment = {
  headers = {
    name           = "standard-headers"
    api_management = { key = "gateway" }
    format         = "xml"
    value          = "<fragment><set-header name=\"X-Content-Type-Options\" exists-action=\"override\"><value>nosniff</value></set-header></fragment>"
    description    = "Reusable response headers; reference from a policy with include-fragment."
  }
}
