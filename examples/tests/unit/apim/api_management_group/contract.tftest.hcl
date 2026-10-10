mock_provider "azurerm" {}

mock_provider "azurecaf" {
  mock_resource "azurecaf_name" {
    override_during = plan
    defaults        = { result = "example-group" }
  }
}

run "group_with_local_references_and_advanced_options" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config = { landingzone_key = "local" }
    remote_objects = {
      api_management = {
        local = {
          apim = { name = "keyed-apim" }
        }
      }
      resource_group = {
        local = {
          rg1 = { name = "keyed-resource-group" }
        }
      }
    }
    settings = {
      name         = "sample-group"
      display_name = "Example Group"
      api_management = {
        key    = "apim"
        lz_key = null
        name   = "direct-apim"
      }
      resource_group = {
        lz_key = null
      }
      resource_group_key = "rg1"
      description        = "Group with external directory association"
      external_id        = "aad://00000000-0000-0000-0000-000000000001/groups/00000000-0000-0000-0000-000000000002"
      type               = "external"
      timeouts = {
        create = "45m"
        read   = "6m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_group.apim.name == "example-group" &&
      azurerm_api_management_group.apim.api_management_name == "keyed-apim" &&
      azurerm_api_management_group.apim.resource_group_name == "keyed-resource-group" &&
      azurerm_api_management_group.apim.display_name == "Example Group" &&
      azurerm_api_management_group.apim.external_id == "aad://00000000-0000-0000-0000-000000000001/groups/00000000-0000-0000-0000-000000000002" &&
      azurerm_api_management_group.apim.type == "external" &&
      azurerm_api_management_group.apim.timeouts.update == "45m"
    )
    error_message = "The group must use CAF naming, resolve local keys, and pass all supported provider options."
  }
}

run "group_with_remote_references_and_legacy_resource_group_key" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config = { landingzone_key = "local" }
    remote_objects = {
      api_management = {
        remote = {
          apim = { name = "remote-apim" }
        }
      }
      resource_group = {
        remote = {
          rg2 = { name = "remote-key-group" }
        }
      }
    }
    settings = {
      name           = "remote-group"
      display_name   = "Remote Group"
      api_management = { key = "apim", lz_key = "remote" }
      resource_group = { key = "rg2", lz_key = "remote" }
      type           = "system"
    }
  }

  assert {
    condition = (
      azurerm_api_management_group.apim.api_management_name == "remote-apim" &&
      azurerm_api_management_group.apim.resource_group_name == "remote-key-group" &&
      azurerm_api_management_group.apim.type == "system"
    )
    error_message = "Remote service references and the legacy resource_group_key must continue to resolve."
  }
}

run "group_with_direct_names_and_provider_default_type" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config  = { landingzone_key = "local" }
    remote_objects = {}
    settings = {
      name         = "direct-group"
      display_name = "Direct Group"
      api_management = {
        name = "direct-apim"
      }
      resource_group = {
        name = "direct-resource-group"
      }
    }
  }

  assert {
    condition = (
      azurerm_api_management_group.apim.api_management_name == "direct-apim" &&
      azurerm_api_management_group.apim.resource_group_name == "direct-resource-group" &&
      azurerm_api_management_group.apim.type == null
    )
    error_message = "Direct dependency names must be supported without overriding the provider's default group type."
  }
}

run "group_rejects_unsupported_type" {
  command         = plan
  expect_failures = [var.settings]

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {
      prefixes      = []
      random_length = 0
      passthrough   = true
      use_slug      = false
    }
    client_config  = { landingzone_key = "local" }
    remote_objects = {}
    settings = {
      name         = "invalid-group"
      display_name = "Invalid Group"
      api_management = {
        name = "direct-apim"
      }
      resource_group = {
        name = "direct-resource-group"
      }
      type = "invalid"
    }
  }
}

run "typed_global_settings_defaults_applied_when_omitted" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {}
    client_config   = { landingzone_key = "local" }
    remote_objects  = {}
    settings = {
      name         = "defaults-group"
      display_name = "Defaults Group"
      api_management = {
        name = "direct-apim"
      }
      resource_group = {
        name = "direct-resource-group"
      }
    }
  }

  assert {
    condition = (
      azurecaf_name.apim.random_length == 0 &&
      azurecaf_name.apim.passthrough == false &&
      azurecaf_name.apim.use_slug == true &&
      azurecaf_name.apim.prefixes == null
    )
    error_message = "Omitted global_settings attributes must fall back to the declared module defaults."
  }
}

run "typed_global_settings_defaults_applied_for_explicit_null" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {
      prefixes      = null
      random_length = null
      passthrough   = null
      use_slug      = null
    }
    client_config  = { landingzone_key = "local" }
    remote_objects = {}
    settings = {
      name         = "defaults-group"
      display_name = "Defaults Group"
      api_management = {
        name = "direct-apim"
      }
      resource_group = {
        name = "direct-resource-group"
      }
    }
  }

  assert {
    condition = (
      azurecaf_name.apim.random_length == 0 &&
      azurecaf_name.apim.passthrough == false &&
      azurecaf_name.apim.use_slug == true &&
      azurecaf_name.apim.prefixes == null
    )
    error_message = "Explicit null global_settings attributes must be replaced by the declared module defaults."
  }
}

run "typed_global_settings_explicit_values_are_preserved" {
  command = plan

  module {
    source = "../modules/apim/api_management_group"
  }

  variables {
    global_settings = {
      prefixes      = ["caf"]
      random_length = 3
      passthrough   = true
      use_slug      = false
    }
    client_config  = { landingzone_key = "local" }
    remote_objects = {}
    settings = {
      name         = "defaults-group"
      display_name = "Defaults Group"
      api_management = {
        name = "direct-apim"
      }
      resource_group = {
        name = "direct-resource-group"
      }
    }
  }

  assert {
    condition = (
      azurecaf_name.apim.random_length == 3 &&
      azurecaf_name.apim.passthrough == true &&
      azurecaf_name.apim.use_slug == false &&
      azurecaf_name.apim.prefixes == tolist(["caf"])
    )
    error_message = "Explicit global_settings values must override the declared module defaults."
  }
}
