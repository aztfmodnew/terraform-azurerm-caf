# API Management workspace named value

Manages `azurerm_api_management_workspace_named_value`. Full
[AzureRM 5.9.0 docs](https://registry.terraform.io/providers/hashicorp/azurerm/5.9.0/docs/resources/api_management_workspace_named_value)
were fetched through Terraform MCP and checked against the installed schema.
Not deprecated.

## Inputs

| Input | Type | Default / purpose |
|---|---|---|
| `settings` | typed object | Required; name, display_name, source and workspace reference |
| `global_settings` | object | `{}`; CAF naming settings |
| `client_config` | object | `{}`; landingzone_key |
| `remote_objects` | object | `{}`; landing-zone keyed api_management_workspace, keyvaults, managed_identities |

Required strings: `name`, `display_name`. `display_name` is not renamed and
remains the identifier used in `{{policy-expressions}}`.
Optional `secret` defaults false, `tags` is a **list of APIM labels**, `value` is
an optional string. No Azure resource tag maps are merged into these labels.
Exactly one of `value` or `value_from_key_vault` must be set; the latter also
requires `secret = true`.

`value_from_key_vault` is an optional singleton object:

- `secret_id`: Key Vault secret URI (provider-required after resolution).
- Alternatively, `key_vault = { key, lz_key? }` plus `secret_name` construct a
  versionless URI from `remote_objects.keyvaults[lz_key][key].vault_uri`.
- `identity_client_id`: optional direct user-assigned identity client ID.
- Alternatively `managed_identity = { key, lz_key? }` resolves
  `remote_objects.managed_identities[lz_key][key].client_id`.
- Direct values take precedence. No identity selection uses APIM's system identity.

Parent precedence: `api_management_workspace_id`,
`api_management_workspace.id`, then
`remote_objects.api_management_workspace[lz_key][key].id`. References accept
`id`, `key`, optional `lz_key` defaulting to `client_config.landingzone_key`.
Optional nullable `timeouts` omits its dynamic block when omitted or explicitly
null, retaining AzureRM's create/read/update/delete defaults 30m/5m/30m/30m.
Inside a supplied object, omitted/null members use these typed defaults; explicit
values override them. `secret` still defaults to false even when explicitly null.
Contracts cover timeout omission/null/custom overrides, not actual operation
durations. All writable attributes and nested arguments are exposed.

**CAF fallback:** public AzureCAF definitions lack the workspace named value
type. The supported `azurerm_api_management_named_value` type supplies compatible
APIM child characters, 80-character maximum and `apimnv` slug.
No invented CAF type is used. No child diagnostic settings/private endpoints apply.
The provider marks values sensitive; secret values can remain in state. Protect
state/plans and inject credentials securely. No value or credential is output.

## Example and tests

[Self-contained example](../../../examples/apim/152-api_management_workspace_named_value/configuration.tfvars)
creates RG, Premium APIM, workspace and a nonsecret backend endpoint.
Review Premium capacity and cost before deployment.
With examples initialized by the parent:

```shell
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_workspace_named_value -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/152-api_management_workspace_named_value/configuration.tfvars -no-color
```

Plan-only contracts mock AzureRM/CAF and assert references/precedence,
CAF fallback, labels and display names, defaults, Key Vault URI/client ID
resolution, system identity, timeouts and each source validation.
They do not validate Azure policy substitution, vault access or secret rotation.
Deploy only in an approved subscription: plan/review/apply this scenario alone,
inspect the named value and destroy with the same file.
Parent owns root and CI integration.

## Outputs

`id`, `name`, `api_management_workspace_id`, `display_name`, `secret`.
