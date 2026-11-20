# API Management gateway host name configuration

Creates `azurerm_api_management_gateway_host_name_configuration` with every
official AzureRM **5.14.0** argument and supported timeout.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management`, `api_management_gateway`, `api_management_certificate` |
| `base_tags` | bool | `false`; unused by this child resource |

Required: `name`, `host_name`, resolvable `api_management_id`, `gateway_name`,
`certificate_id`. Parent aliases are `api_management`, `gateway`, `certificate`.
All accept id or key/lz_key; gateway additionally accepts name and resolves
ID-only parent outputs to a name. Direct provider arguments win, then explicit
alias fields, then remote `[lz_key][key]` maps. Absent/null lz_key uses the
client landing zone.

Optional: `request_client_certificate_enabled`, `http2_enabled` (default true,
including explicit null), `tls10_enabled`, `tls11_enabled`, `timeouts`.
Unspecified flags except HTTP/2 are delegated to AzureRM. For new deployments,
explicitly disable TLS 1.0/1.1; the example does so.

Exact public CAF type: `azurerm_api_management_gateway_host_name_configuration`.
Global naming flags including passthrough are supported. Timeouts default to
30m for create/update/delete and 5m for read. No fake location, Azure tags,
diagnostic or private-endpoint child configuration is added.

## Outputs and example

Outputs: `id`, generated `name`, configured `host_name`, resolved `gateway_name`.
See [128-api_management_gateway_host_name_configuration](../../../examples/apim/128-api_management_gateway_host_name_configuration).
Provision DNS and a matching certificate separately.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_gateway_host_name_configuration
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_gateway_host_name_configuration -no-color
```

Requires Terraform >=1.9, AzureRM 5.14.0 and AzureCAF; both providers are mocked.
Plan assertions cover local/remote parents, ID-only gateway outputs, direct
precedence, all protocol flags, HTTP/2 omission/null default and timeouts.
DNS, TLS handshakes and certificate validation are not tested.
