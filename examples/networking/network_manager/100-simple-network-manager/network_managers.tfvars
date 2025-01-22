network_managers = {
  network_manager_1 = {
    name               = "network_manager_1"
    resource_group_key = "test_re1"
    /* subscriptions = [
    {
      lz_key = "lz-key-1"
      key    = "key-1"
    },
    {
      lz_key = "lz-key-2"
      key    = "key-2"
    }
  ]*/
    scope = {
      #"management_group_ids" = ["/providers/Microsoft.Management/managementGroups/00000000-0000-0000-0000-000000000000","/providers/Microsoft.Management/managementGroups/11111111-1111-1111-1111-111111111111"]
      #"subscription_ids" = ["/subscriptions/00000000-0000-0000-0000-000000000000", "/subscriptions/11111111-1111-1111-1111-111111111111"]
      # By default the network manager will be created in the same subscription as the terraform is launched
    }
    scope_accesses = ["Connectivity", "SecurityAdmin", "Routing"]
    description    = "Test Network Manager"
    tags = {
      "Environment" = "Test"
    }
  }
}

