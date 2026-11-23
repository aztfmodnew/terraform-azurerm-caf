# API Management

The CAF root exposes API Management resources under `apim`. Each collection
uses the corresponding module name, for example `api_management_workspace` or
`api_management_policy_fragment`. The example wrapper accepts these collections
as top-level variables in its `.tfvars` files.

The implementation targets the AzureRM version constrained by the CAF root.
Resource arguments, nested blocks and supported timeout operations are
validated against provider documentation and the installed provider schema.
See the [APIM example guide](../../examples/apim/README.md) and the child-module
READMEs, where provided, for inputs and focused contracts.

## Dependencies and existing resources

Pass resource settings unchanged to the root `apim` collections. Dependency
resolution follows each collection's existing contract: some root aggregators
resolve parent names or IDs into dedicated child inputs; other child modules
resolve them through `remote_objects`. Use the collection's documented
direct-name/ID inputs or `{ key, lz_key? }` references. Omitted `lz_key` selects
the current landing zone.
Logical APIM identifiers, such as a product identifier or operation identifier,
are distinct from ARM resource IDs.

The root's `data_sources_lookup.tf` supports all API Management data sources
provided by AzureRM:

| Collection | Lookup selectors |
| --- | --- |
| `api_management` | `name`, `resource_group_name` |
| `api_management_api` | `name`, `api_management_name`, `resource_group_name`, `revision` |
| `api_management_api_version_set` | `name`, `api_management_name`, `resource_group_name` |
| `api_management_gateway` | `name`, `api_management_id` |
| `api_management_gateway_host_name_configuration` | `name`, `api_management_id`, `gateway_name` |
| `api_management_group` | `name`, `api_management_name`, `resource_group_name` |
| `api_management_product` | `product_id`, `api_management_name`, `resource_group_name` |
| `api_management_subscription` | `subscription_id`, `api_management_id` |
| `api_management_user` | `user_id`, `api_management_name`, `resource_group_name` |
| `api_management_workspace` | `name`, `api_management_id` |

These are real Azure names, not CAF naming inputs. Every lookup accepts an
optional `timeouts = { read = "10m" }`. An explicit `id` bypasses lookup.
Resolved entries and explicit IDs are available under the current landing-zone
key in the corresponding combined collection. Legacy landing-zone keyed
explicit-ID entries remain supported. Incomplete name-only entries are not
exported as resolved resources.

Do not store secrets directly in committed `.tfvars`. Use secure variable
injection or Key Vault references where the provider supports them. APIM named
value `tags` are label lists, not Azure resource tag maps.

## Policies and associations

The product module retains its existing embedded policy and association
settings. Independent product policy/API/group collections allow managing these
relationships for existing or remote products. Do not configure the same
relationship or policy through both interfaces.

Self-hosted gateway resource definitions do not install gateway software.
Policy XML, API schemas and policy fragments are infrastructure configuration;
application deployment remains outside this module family.

## Validation

The numbered examples under `examples/apim/` use the shared mock plan runner.
From `examples/`:

```sh
terraform init -backend=false
terraform test -test-directory=tests/mock -var-file=apim/119-api_management_named_value/configuration.tfvars
```

For the existing `109-api_management_custom_domain` and
`111-api_management_certificate` examples, also pass the same directory's
`certificates.tfvars`; it contains the complementary certificate definitions.

Behavioral contracts are opt-in under `examples/tests/unit/apim/`. Select each
suite's exact directory; Terraform does not discover nested suites recursively.
For example:

```sh
terraform init -backend=false -test-directory=tests/unit/apim/data_sources
terraform test -test-directory=tests/unit/apim/data_sources
```

Contracts and example plans use mocked providers and do not prove service-side
acceptance, SKU/region availability or permissions. No live Azure deployment is
performed by these tests.

Provider reference:
[API Management resources and data sources](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).
