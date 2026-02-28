mock_provider "azurerm" {
  source = "./tests/mock_data"

  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock_rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mock_identity"
      principal_id = "00000000-0000-0000-0000-000000000001"
      client_id    = "00000000-0000-0000-0000-000000000002"
      tenant_id    = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      oidc_issuer_url = "https://mock-oidc-issuer.example.com/"
    }
  }
}

mock_provider "azurerm" {
  alias  = "vhub"
  source = "./tests/mock_data"

  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock_rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mock_identity"
      principal_id = "00000000-0000-0000-0000-000000000001"
      client_id    = "00000000-0000-0000-0000-000000000002"
      tenant_id    = "00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azuread" {
  source = "./tests/mock_data"
}

run "test_plan" {
  // E2E plan test the examples
  command = plan
}