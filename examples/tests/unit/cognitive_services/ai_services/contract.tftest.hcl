mock_provider "azurerm" {}
mock_provider "azurecaf" {}

variables {
  global_settings = {
    prefixes       = []
    suffixes       = []
    random_length  = 0
    passthrough    = true
    use_slug       = false
    environment    = "test"
    default_region = "region1"
    regions        = { region1 = "westeurope" }
  }
  client_config  = { landingzone_key = "local" }
  location       = "westeurope"
  resource_group = { name = "migrationtest", location = "westeurope", tags = {} }
  base_tags      = false
  remote_objects = {
    vnets = {
      local = {
        ai = {
          subnets = {
            private_endpoints = {
              id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualNetworks/ai/subnets/private-endpoints"
            }
          }
        }
      }
    }
    virtual_subnets = {
      local = {
        private_endpoints = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualNetworks/ai/subnets/private-endpoints"
        }
      }
    }
    private_dns = {
      local = {
        cognitive = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
        }
        openai = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
        }
        services_ai = {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com"
        }
      }
    }
  }
}

run "project_management_defaults_to_system_identity" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    settings = { name = "migrationtest", sku_name = "S0" }
  }
  assert {
    condition     = azurerm_cognitive_account.ai_services.kind == "AIServices" && azurerm_cognitive_account.ai_services.project_management_enabled && azurerm_cognitive_account.ai_services.identity[0].type == "SystemAssigned"
    error_message = "The legacy AI Services mode requires a default system-assigned identity."
  }
}
run "disabled_projects_do_not_inject_identity" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    settings = {
      name                         = "migrationtest"
      sku_name                     = "S0"
      project_management_enabled   = false
      public_network_access        = "Disabled"
      local_authentication_enabled = false
    }
  }
  assert {
    condition     = length(azurerm_cognitive_account.ai_services.identity) == 0 && !azurerm_cognitive_account.ai_services.public_network_access_enabled && !azurerm_cognitive_account.ai_services.local_auth_enabled
    error_message = "Disabled project management must not inject an identity, and legacy network/auth flags must be preserved."
  }
}
run "explicit_identity_and_current_flags_are_preserved" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    remote_objects = {
      managed_identities = {
        local = {
          test = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test" }
        }
      }
    }
    settings = {
      name                          = "migrationtest"
      sku_name                      = "S0"
      public_network_access         = "Disabled"
      public_network_access_enabled = true
      local_authentication_enabled  = false
      local_auth_enabled            = true
      identity = {
        type                  = "UserAssigned"
        managed_identity_keys = ["test"]
      }
    }
  }
  assert {
    condition     = azurerm_cognitive_account.ai_services.identity[0].type == "UserAssigned" && azurerm_cognitive_account.ai_services.identity[0].identity_ids == toset([var.remote_objects.managed_identities.local.test.id]) && azurerm_cognitive_account.ai_services.public_network_access_enabled && azurerm_cognitive_account.ai_services.local_auth_enabled
    error_message = "Explicit identities and current network/auth settings must take precedence."
  }
}

run "private_endpoint_forces_account_subresource_and_preserves_dns" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    remote_objects = {
      vnets = {
        local = {
          ai = {
            subnets = {
              private_endpoints = {
                id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualNetworks/ai/subnets/private-endpoints"
              }
            }
          }
        }
      }
      virtual_subnets = {
        local = {
          private_endpoints = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualNetworks/unrelated/subnets/private-endpoints"
          }
        }
      }
      private_dns = {
        local = {
          cognitive = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
          }
          openai = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
          }
          services_ai = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com"
          }
        }
      }
    }
    private_endpoints = {
      ai = {
        name       = "ai"
        vnet_key   = "ai"
        subnet_key = "private_endpoints"
        private_service_connection = {
          name              = "ai"
          subresource_names = ["incorrect"]
        }
        private_dns = {
          zone_group_name = "ai-services"
          keys            = ["cognitive", "openai", "services_ai"]
        }
      }
      direct = {
        name      = "ai-direct"
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.Network/virtualNetworks/direct/subnets/private-endpoints"
        private_service_connection = {
          name = "ai-direct"
        }
      }
    }
    settings = {
      name                          = "private"
      sku_name                      = "S0"
      custom_subdomain_name         = "private"
      public_network_access_enabled = false
      network_acls = {
        bypass         = "AzureServices"
        default_action = "Deny"
      }
    }
  }
  assert {
    condition = (
      output.private_endpoints["ai"].private_service_connection[0].subresource_names[0] == "account" &&
      toset(output.private_endpoints["ai"].private_dns_zone_group[0].private_dns_zone_ids) == toset([
        var.remote_objects.private_dns.local.cognitive.id,
        var.remote_objects.private_dns.local.openai.id,
        var.remote_objects.private_dns.local.services_ai.id
      ]) &&
      output.private_endpoints["ai"].subnet_id == var.remote_objects.vnets.local.ai.subnets.private_endpoints.id &&
      output.private_endpoints["direct"].subnet_id == var.private_endpoints.direct.subnet_id &&
      azurerm_cognitive_account.ai_services.network_acls[0].default_action == "Deny" &&
      azurerm_cognitive_account.ai_services.network_acls[0].bypass == "AzureServices" &&
      !azurerm_cognitive_account.ai_services.public_network_access_enabled
    )
    error_message = "AI Services private endpoints must force account, retain DNS zone integration, and not replace network ACLs."
  }
}

run "private_endpoint_defaults_to_account_subresource" {
  command = plan
  module {
    source = "../modules/cognitive_services/ai_services"
  }
  variables {
    private_endpoints = {
      ai = {
        name       = "ai-default"
        vnet_key   = "ai"
        subnet_key = "private_endpoints"
        private_service_connection = {
          name = "ai-default"
        }
      }
    }
    settings = {
      name                  = "private-default"
      sku_name              = "S0"
      custom_subdomain_name = "private-default"
    }
  }
  assert {
    condition     = output.private_endpoints["ai"].private_service_connection[0].subresource_names == tolist(["account"])
    error_message = "AI Services private endpoints must default to the account subresource."
  }
}
