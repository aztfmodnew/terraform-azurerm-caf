# API Management standalone workspace gateway

Creates `azurerm_api_management_standalone_gateway` using every official
AzureRM **5.14.0** argument, required SKU block and supported timeout.
This is a workspace gateway, **not** an APIM self-hosted gateway resource.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; naming, regions and global tags |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `resource_groups`, optional `vnets` |
| `resource_group` | any | `null`; optional resolved group |
| `location` | string | `null`; optional caller region |
| `base_tags` | bool | `false`; opt into global/group tag inheritance |

Required settings: `name`, `sku = { name = "WorkspaceGatewayPremium",
capacity = optional-number }`, resolvable group name and location.
Capacity defaults to 1, including explicit null.
Optional: `backend_subnet_id`, `virtual_network_type` (`External` or `Internal`),
`tags`, `timeouts`. Group alias accepts name/id/key/lz_key. Subnet alias accepts
id or `{ vnet_key, key, lz_key? }`, resolving
`remote_objects.vnets[lz_key][vnet_key].subnets[key].id`.
Direct provider arguments override alias fields and remote lookups.
Null/omitted lz_key uses the client landing zone.
Supply `virtual_network_type` and a backend subnet together, or omit both;
the module validates this provider pairing requirement before planning.

Location order: settings.location, caller location, settings.region in global
regions, caller group location, remote group location, global default region.
Tag order when inheritance is enabled: global, remote group, caller group,
module tag, settings tags. Without inheritance only module/settings tags apply.
Backend subnet must satisfy Azure's workspace gateway network/delegation rules.

## CAF naming

Public [`resourceDefinition.json`](https://github.com/aztfmodnew/terraform-provider-azurecaf/blob/main/resourceDefinition.json)
has **no** `azurerm_api_management_standalone_gateway` entry. The supported
`azurerm_api_management` rule is used as a conservative compatible subset:
alphanumeric/dash, maximum 50 characters. The complete standalone gateway name
is then limited to 45 characters, preserving the configured random suffix at
the end when the generated name must be shortened. Global naming flags apply.
Use `global_settings.passthrough = true` for a pre-validated existing name;
passthrough skips CAF transformation, not Azure's name constraints.
No unsupported naming type is invented.

Timeouts default to 30m create/update/delete and 5m read. No diagnostic or
private-endpoint blocks are invented from the resource's provider schema.

## Outputs and example

Outputs: `id`, generated `name`, resolved `location`, `resource_group_name`.
See [147-api_management_standalone_gateway](../../../examples/apim/147-api_management_standalone_gateway).
The example creates its resource group, VNet and dedicated delegated subnet.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_standalone_gateway
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_standalone_gateway -no-color
```

From the root use Terraform >=1.9, AzureRM 5.14.0 and AzureCAF. Both providers are
mocked and runs plan. Tests check local/remote subnet/group resolution, direct
precedence, region selection, SKU capacity omission/null/value, opt-in tag
inheritance/precedence, network type, CAF fallback and timeouts. Regional SKU
availability, subnet suitability and service-side provisioning remain unverified.
