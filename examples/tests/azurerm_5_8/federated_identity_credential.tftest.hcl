mock_provider "azurerm" {}

run "federated_credential_direct_identity_id" {
  command = plan
  module {
    source = "../modules/security/mi_federated_credentials"
  }
  variables {
    client_config = { landingzone_key = "local" }
    settings = {
      name                      = "migrationtest"
      subject                   = "system:serviceaccount:demo:workload-identity-sa"
      oidc_issuer_url           = "https://oidc.example.com/"
      user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test"
    }
  }
  assert {
    condition     = azurerm_federated_identity_credential.fed_cred.user_assigned_identity_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/migrationtest/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test"
    error_message = "The direct user_assigned_identity_id input must be passed to the resource."
  }
}
