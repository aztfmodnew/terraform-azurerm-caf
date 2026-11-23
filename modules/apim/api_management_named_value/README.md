# API Management named values

Creates plain, secret, or Key Vault-backed named values. Configure the CAF root
through `apim.api_management_named_value`; the examples wrapper exposes the same
collection as `api_management_named_value`.

The resource name uses CAF naming. `display_name` is kept unchanged because APIM
policies reference it as `{{backend-endpoint}}`. `tags` are APIM label strings;
Azure resource tags and CAF module tags are not inherited. This child resource
does not have independent location, diagnostics, or private endpoints.

Use `api_management` and `resource_group` references with `key` and optional
`lz_key`, or provide their explicit names. For Key Vault-backed values:

```hcl
settings = {
  name         = "backend-token"
  display_name = "backend-token"
  secret       = true
  api_management = { key = "gateway" }
  resource_group = { key = "gateway" }
  value_from_key_vault = {
    key_vault        = { key = "gateway" }
    secret_name      = "backend-token"
    managed_identity = { key = "gateway" }
  }
}
```

Alternatively provide `value_from_key_vault.secret_id` directly and optionally
`identity_client_id`; explicit values take precedence over key-based references.
Without an identity selector APIM uses its system-assigned identity. The selected
identity must already be attached to APIM and granted access to the existing
secret. The module does not read or create that secret. A versionless URI allows
APIM to refresh rotated secrets. Do not put secret contents in committed tfvars.
Setting `secret = true` encrypts the value in APIM, but does not keep an inline
`value` out of Terraform state.

Schema validated against AzureRM 5.14.0
[`api_management_named_value`](https://registry.terraform.io/providers/hashicorp/azurerm/5.14.0/docs/resources/api_management_named_value)
using Terraform MCP. Key Vault access requirements:
[Microsoft Learn](https://learn.microsoft.com/azure/api-management/api-management-howto-properties).

## Verification

From `examples`, initialize and run the self-contained example:

```shell
terraform init -backend=false
terraform test -test-directory=tests/mock -var-file=apim/119-api_management_named_value/configuration.tfvars
```

The isolated contracts mock AzureRM and CAF naming. They verify literal values,
Key Vault and identity resolution (local and remote landing zones), explicit
overrides, optional defaults and invalid Key Vault configuration. They do not
verify Azure permissions, secret availability, or runtime policy behavior.

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_named_value
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_named_value
```
