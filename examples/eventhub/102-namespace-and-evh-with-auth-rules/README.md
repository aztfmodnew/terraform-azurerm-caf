# Event Hubs namespace, hubs and authorization rule

The standalone hub exercises the legacy namespace-name/resource-group lookup.
The nested hub exercises the current namespace ARM ID passed by the namespace
module. Both use the AzureRM 5.8 `namespace_id` resource argument.

Direct callers of the hub submodule can provide `namespace_id` for an existing
namespace. For an ID computed during apply, use `namespace = { id = ... }`:
the reference object is known during planning even when its ID is not, so the
lookup count remains stable. This object takes precedence over `namespace_id`.
If both are omitted, `namespace_name` and `resource_group_name` remain supported
through a namespace data lookup.

```bash
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=./eventhub/102-namespace-and-evh-with-auth-rules/configuration.tfvars
```

Validated against the [AzureRM 5.8 Event Hub schema](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/eventhub).
