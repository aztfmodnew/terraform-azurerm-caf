# API Management workspace certificate

Manages `azurerm_api_management_workspace_certificate`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_workspace_certificate)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; name, certificate source and parent reference |
| `global_settings` | object | `{}`; CAF naming settings |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; api_management_workspace, keyvaults, keyvault_certificates, keyvault_certificate_requests, managed_identities |

`name` is required. Optional strings `certificate_data_base64` (PKCS#12 PFX),
`password`, `key_vault_secret_id`, `user_assigned_identity_client_id` default
null. All writable provider attributes are exposed. Exactly one of inline data
or a Key Vault source is required; `password` requires inline data and identity
selection requires a Key Vault source.

Parent precedence: `api_management_workspace_id`,
`api_management_workspace.id`, then
`remote_objects.api_management_workspace[lz_key][key].id`.
Key Vault source precedence:

1. `key_vault_secret_id` (secret **URI**, not certificate ARM ID).
2. `key_vault_secret = { certificate_key, lz_key? }` resolves
   `remote_objects.keyvault_certificates[lz_key][certificate_key].secret_id`.
3. `key_vault_secret = { certificate_request_key, lz_key? }` resolves
   `remote_objects.keyvault_certificate_requests[lz_key][certificate_request_key].secret_id`.
4. `key_vault = { key, lz_key? }` and `secret_name` construct a versionless URI
   from `remote_objects.keyvaults[lz_key][key].vault_uri`.

Within `key_vault_secret`, set exactly one of its two key fields.
`managed_identity = { key, lz_key? }` resolves
`remote_objects.managed_identities[lz_key][key].client_id`, unless the explicit
`user_assigned_identity_client_id` is supplied. Omitting both uses APIM's system
identity. All reference landing zones default to `client_config.landingzone_key`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. Contracts cover omission/null/custom overrides, not actual
operation durations.

**CAF fallback:** AzureCAF's public definitions lack
`azurerm_api_management_workspace_certificate`. The supported service-level
`azurerm_api_management_certificate` type is used instead, with compatible APIM
child characters, 80-character limit and `apimcert` slug. Global naming options
remain supported. No child Azure tag maps, diagnostics or private endpoints apply.
Private key bytes/passwords remain in state when supplied inline; protect state,
inject secrets securely, and prefer Key Vault references. No secret is output.

## Example and tests

[Self-contained certificate example](../../../examples/apim/151-api_management_workspace_certificate/configuration.tfvars)
creates RG, Premium APIM/workspace, user-assigned identity, vault, access policy
and a self-signed certificate request. Review Premium costs and Key Vault
permissions/retention. IAM propagation can require a later retry; mocks do not
establish access-policy propagation or certificate acceptance.

With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_workspace_certificate -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/151-api_management_workspace_certificate/configuration.tfvars -no-color
```

AzureRM/CAF-mocked plan-only contracts check local/cross-zone resolution,
secret URIs/client IDs, system identity, inline data, direct precedence, CAF
fallback, timeouts and certificate source validation. Inline test bytes are
synthetic, not a deployable PFX. Use an approved subscription for deployment,
plan/review/apply this scenario alone, inspect the certificate and destroy with
the same file. Account for Key Vault soft-delete retention during cleanup.
Root/CI integration belongs to the parent.

## Outputs

`id`, `name`, `api_management_workspace_id`, `expiration`, `subject`, `thumbprint`.
