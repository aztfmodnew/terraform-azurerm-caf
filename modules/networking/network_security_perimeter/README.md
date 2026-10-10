# Network security perimeter (AzAPI)

This module retains AzAPI and uses the stable `2025-07-01` API for the perimeter,
profiles, access rules, resource associations, links, logging configurations,
and link-reference lookups.
The CAF root selects AzAPI **2.13.x**. Although ARM documents `2025-09-01`, the
released AzAPI schemas through 2.13.0 include these resources only through
`2025-07-01`. Schema validation remains enabled.
Terraform **1.7 or later** is required for the declarative link-reference state
transition; the CAF root already requires Terraform 1.8.

The AzAPI provider configuration and version constraint are retained only in the
CAF root module. This module declares only its `azure/azapi` source requirement,
without another version constraint or provider configuration. Terraform inherits
provider configurations, not source requirements; omitting the source would
incorrectly infer the nonexistent `hashicorp/azapi` provider.

Existing perimeter and child names and managed-resource addresses are unchanged.
CAF naming is intentionally not enabled in this update because renaming existing
perimeters would replace them.

## Configuration

Use `networking.network_security_perimeters` in the root module, or
`network_security_perimeters` in the examples wrapper. See the
[basic example](../../../examples/networking/network_security_perimeter/100-nsp-basic-deployment/configuration.tfvars)
and [advanced example](../../../examples/networking/network_security_perimeter/300-nsp-advanced-deployment/network_security_perimeters.tfvars).

- `profiles`: a map of profile names.
- `access_rules`: a map with `name`, `direction` (`Inbound` or `Outbound`),
  `profile_key` or `profile_id`, and the relevant rule properties. Use public
  address prefixes for inbound access and FQDNs for outbound access.
  Subscription rules accept objects with `id` in ARM subscription ID format.
  Email, phone-number, and service-tag rules are exposed by the schema but
  documented as unavailable; do not use them for deployments.
- `resource_associations`: a map with `name`, `access_mode`, `profile_key` or
  `profile_id`, and either `private_link_resource_id` or the existing key-based
  `storage_account`, `keyvault`, `event_hub_namespace`, `cosmos_db`, or `mssql_server`
  reference. References support `key` and optional `lz_key`. Direct IDs take
  precedence. Start with `Learning` and review traffic before using `Enforced`.
  The old `event_hub` reference remains supported, but Event Hubs perimeter
  associations target the namespace; use `event_hub_namespace` for new configurations.
- `links`: a map with `name`, optional `description` (maximum 140 characters),
  `auto_approved_remote_perimeter_resource_id`, `local_inbound_profiles`, and
  `remote_inbound_profiles`. Auto-approval requires the
  `Microsoft.Network/networkSecurityPerimeters/linkPerimeter/action` permission
  on the remote perimeter. Links wait for local profiles to be created.
- `link_references`: a map of **existing** reference names to read. Azure creates
  these on the receiving perimeter when a link is established; they cannot be
  created by PUT. Reads wait for links managed by this module, but external link
  creation must be completed before using this lookup.
- `diagnostic_profiles`: retains the shared CAF diagnostics integration.
- `logging_configurations`: an optional map with `name`, `enabled_log_categories`,
  `version`, and `timeouts`, separate from diagnostic destination settings.
- `timeouts`: optional `create`, `read`, `update`, and `delete` duration strings
  on the perimeter and each managed child.

Only the perimeter supports `location` and `tags`. Legacy child location/tag
inputs remain accepted but are no longer sent to ARM. Unset optional access-rule
and link properties are omitted from requests.

## Outputs

`network_security_perimeter_id` is retained. `id` is an equivalent alias.
`profiles`, `access_rules`, `resource_associations`, `links`, and
`link_references`, and `logging_configurations` expose their objects indexed by configuration key.

## Migration of existing link-reference state

Existing `azapi_resource.linkReferences` instances are now
`data.azapi_resource.linkReferences` lookups, because the official REST API
supports GET and DELETE but no PUT. There is no resource-to-data-source state
move.

The module includes a Terraform `removed` block with `destroy = false`. Once
provider resolution is restored, a normal reviewed plan/apply removes only the
old managed-resource entries from state, without deleting the Azure references,
and reads them through data sources. No manual state command is required. Keep
the `removed` block until every consuming state has migrated. The input map still
uses the same keys and names. Do not apply a plan that proposes deleting the old
link references.

## Validation sources

The Terraform MCP tools were not used for these AzAPI resources; schemas were checked
against official Microsoft ARM documentation, the REST specification, and the
released AzAPI provider schema/documentation:

- [Perimeter](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters)
- [Profiles](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters/profiles)
- [Access rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters/profiles/accessrules)
- [Resource associations](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters/resourceassociations)
- [Links](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters/links)
- [Link references](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters/linkreferences)
- [Logging configurations](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/2025-07-01/networksecurityperimeters/loggingconfigurations)
- [Event Hubs namespace associations](https://learn.microsoft.com/en-us/azure/event-hubs/network-security-perimeter)
- [REST operations](https://github.com/Azure/azure-rest-api-specs/blob/main/specification/network/resource-manager/Microsoft.Network/Network/stable/2025-07-01/networkSecurityPerimeter.json)
- [AzAPI 2.13.0 embedded schemas](https://github.com/Azure/terraform-provider-azapi/tree/v2.13.0/internal/azure/generated/network/microsoft.network/2025-07-01)
- [AzAPI resource and timeouts](https://github.com/Azure/terraform-provider-azapi/blob/v2.13.0/docs/resources/resource.md)
- [Terraform removed blocks](https://developer.hashicorp.com/terraform/language/block/removed)

## Mock tests

From the repository root:

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/mock
terraform -chdir=examples test -test-directory=tests/mock -var-file=networking/network_security_perimeter/100-nsp-basic-deployment/configuration.tfvars
```

The tests use mock providers and do not contact Azure. For the advanced example,
pass every `.tfvars` file in its directory as documented in its
[README](../../../examples/networking/network_security_perimeter/300-nsp-advanced-deployment/README.md).
Both examples use the existing shared runner selected by the networking
workflows; there is no separate perimeter test suite.

These tests check plan generation and framework dependency wiring, not
service-side enforcement, connectivity, or acceptance of API requests by Azure.
The shared runner has no behavior-specific assertions. Initialization requires
valid provider-source resolution, including the child source-only requirements
described above.

Follow the [shared test guidelines](../../../examples/tests/README.md) before
adding module-specific assertions or changing CI test selection.
