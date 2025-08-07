mock_data "azurerm_client_config" {
  defaults = {
    client_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
  }
}

mock_data "azuread_client_config" {
  defaults = {
    client_id       = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
  }
}

mock_data "azurerm_subscription" {
  defaults = {
    id              = "/subscriptions/00000000-0000-0000-0000-000000000001"
    subscription_id = "00000000-0000-0000-0000-000000000001"
    display_name    = "mock_subscription"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
  }
}

mock_data "azuread_service_principal" {
  defaults = {
    client_id                    = "00000000-0000-0000-0000-000000000000"
    application_id               = "00000000-0000-0000-0000-000000000000"
    display_name                 = "mock_service_principal"
    object_id                    = "00000000-0000-0000-0000-000000000000"
    application_tenant_id        = "00000000-0000-0000-0000-000000000000"
    account_enabled              = true
    app_role_assignment_required = false
    service_principal_names      = ["https://identity.azure.net/P2P_lKTqRFRnoEaUQBcF9VQig1w"]
    tags                         = []
    type                         = "Application"
  }
}

mock_data "azurerm_role_definition" {
  defaults = {
    id          = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    description = "Contributor"
    type        = "BuiltInRole"
  }

}
