global_settings = {
  default_region = "primary"
  regions        = { primary = "westeurope" }
  random_length  = 5
}

resource_groups = {
  gateway = { name = "group-membership", region = "primary" }
}
api_management = {
  gateway = {
    name           = "group-membership", region = "primary", resource_group = { key = "gateway" }
    publisher_name = "Example", publisher_email = "operations@example.com", sku_name = "Developer_1"
  }
}
api_management_group = {
  consumers = {
    name           = "consumers", display_name = "API consumers", type = "custom"
    api_management = { key = "gateway" }, resource_group = { key = "gateway" }
  }
}
api_management_user = {
  developer = {
    user_id        = "example-developer", first_name = "Example", last_name = "Developer", email = "developer@example.com", state = "active"
    api_management = { key = "gateway" }, resource_group = { key = "gateway" }
  }
}

api_management_group_user = {
  consumer = {
    user           = { key = "developer" }
    group          = { key = "consumers" }
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
