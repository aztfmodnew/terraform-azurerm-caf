# Azure Managed Redis Module

This module deploys an Azure Managed Redis instance using CAF naming and supports managed identities, customer-managed keys, default database configuration, diagnostic settings, access-policy assignments, and private endpoints.

## Usage

The module configuration is passed through `settings`. The required module inputs are `global_settings`, `client_config`, `settings`, and `resource_group`.

```hcl
module "managed_redis" {
  source = "./modules/cache/managed_redis"

  global_settings = var.global_settings
  client_config   = var.client_config
  resource_group  = var.resource_group
  settings        = var.managed_redis_settings

  base_tags = true

  remote_objects = {
    managed_identities = var.managed_identities
    private_dns        = var.private_dns
    virtual_subnets    = var.virtual_subnets
    vnets              = var.vnets
  }

  # These are separate module inputs, not attributes of settings.
  diagnostic_profiles = {}
  diagnostics         = {}
  private_endpoints   = {}
}
```

`resource_group` must provide the resource group `name` and `location`. `location` and `resource_group_name` can instead be supplied as explicit overrides. `base_tags` controls whether global and resource-group tags are merged with `settings.tags`.

### Module inputs

| Name | Description | Required |
| --- | --- | --- |
| `global_settings` | Global CAF settings | Yes |
| `client_config` | Client and landing-zone configuration | Yes |
| `settings` | Managed Redis configuration object | Yes |
| `resource_group` | Resource group object with `name` and `location` | Yes |
| `location` | Optional location override | No |
| `resource_group_name` | Optional resource group name override | No |
| `base_tags` | Whether to merge global and resource-group tags | No |
| `remote_objects` | Managed identities and networking dependencies | No |
| `diagnostic_profiles` | Diagnostic profiles to create | No |
| `diagnostics` | Diagnostic destinations | No |
| `private_endpoints` | Private endpoint configurations | No |
| `private_dns` | Fallback private DNS zones | No |
| `vnets` | Fallback virtual networks | No |
| `virtual_subnets` | Fallback virtual subnets | No |

### Settings

```hcl
managed_redis_settings = {
  name                      = "redis-instance-1"
  resource_group_key        = "rg_key"
  sku_name                  = "Balanced_B3"
  high_availability_enabled = true
  public_network_access     = "Enabled"

  identity = {
    type = "SystemAssigned"
  }

  default_database = {
    access_keys_authentication_enabled = true
    client_protocol                    = "Encrypted"
    eviction_policy                    = "AllKeysLRU"
    modules = [{
      name = "search"
      args = "ARGS"
    }]
  }

  timeouts = {
    create = "45m"
    read   = "5m"
    update = "30m"
    delete = "30m"
  }

  tags = {
    environment = "dev"
  }
}
```

To preserve an existing Managed Redis physical name, set `name_override` to that exact Azure name:

```hcl
managed_redis_settings = {
  name          = "redis-instance-1"
  name_override = "existing-managed-redis-name"
  sku_name      = "Balanced_B3"
}
```

When `name_override` is set, the module passes the value through azurecaf unchanged. CAF prefixes, random suffixes, input cleaning, and `global_settings.passthrough` do not alter it. The override must already satisfy Azure Managed Redis naming rules; it does not rename an existing resource by itself. To migrate an existing deployment without replacement, set `name_override` to the resource's current physical name before planning, and ensure the rest of the configuration matches the existing resource.

If `name_override` is omitted, naming behaves exactly as before: `settings.name` is processed using the existing Managed Redis CAF naming configuration, prefixes, random length, cleaning, and global passthrough settings.

`sku_name` is required. Use a supported Managed Redis SKU such as `Balanced_B3`; do not use the legacy Standard or Premium SKU names. `high_availability_enabled` defaults to `true`, and `public_network_access` defaults to `Enabled`.

The optional `default_database` block supports database settings and a `modules` list. Each module entry has a required `name` and an optional `args` value.

The optional `customer_managed_key` block accepts `key_vault_key_id` and `user_assigned_identity_id`. The optional database fields `clustering_policy`, `geo_replication_group_name`, `persistence_append_only_file_backup_frequency`, and `persistence_redis_database_backup_frequency` can be added when required by the deployment.

### Managed identities

Identity references use keys resolved from `remote_objects.managed_identities`:

```hcl
identity = {
  type                  = "UserAssigned"
  managed_identity_keys = ["redis_client"]
  remote = {
    remote_lz = {
      managed_identity_keys = ["shared_redis_identity"]
    }
  }
}
```

`managed_identity_keys` refers to identities in the current landing zone. Entries under `remote` refer to identities in the specified landing zone key.

### Access-policy assignments

Use `redis_role_assignment` to group managed identity object assignments:

```hcl
redis_role_assignment = {
  "Data Owner" = {
    managed_identities = {
      keys = ["redis_client"]
    }
  }
}
```

The map keys, such as `Data Owner`, are configuration grouping labels only. The provider resource used by this module accepts `managed_redis_id` and `object_id`; it does not accept a role argument. Identity object IDs are resolved from `remote_objects.managed_identities`. Add `lz_key` to `managed_identities` when the identities are in another landing zone.

The `settings.timeouts` values are also used for access-policy assignment create, read, and delete operations. Update timeouts apply to the Managed Redis resource only.

### Diagnostics

Diagnostic profiles are supplied separately from `settings`:

```hcl
diagnostic_profiles = var.diagnostic_profiles
diagnostics         = var.diagnostics
```

`diagnostic_profiles` controls which profiles are created. `diagnostics` (or `remote_objects.diagnostics`) supplies the diagnostic destinations.

### Private endpoints

Private endpoints are supplied through the separate `private_endpoints` input. Subnets can be resolved from `remote_objects.virtual_subnets` or from `remote_objects.vnets`; private DNS zones can be resolved from `remote_objects.private_dns`. The parent module creates the private endpoint through its networking submodule, but it does not expose private endpoint IDs or endpoint objects as outputs.

```hcl
private_endpoints = {
  pe1 = {
    name               = "managed-redis-pe1"
    vnet_key           = "vnet1"
    subnet_key         = "pep"
    private_dns = {
      zone_group_name = "managed-redis"
      keys            = ["managed_redis_dns"]
    }
    private_service_connection = {
      name                 = "managed-redis-psc"
      is_manual_connection = false
      subresource_names    = ["redisEnterprise"]
    }
  }
}
```

## Outputs

| Name | Description |
| --- | --- |
| `id` | Managed Redis instance ID |
| `hostname` | Managed Redis hostname |
| `default_database` | Default database details, including its ID, port, and access keys when available |

## Examples

- [`100-simple-managed-redis`](../../../examples/cache/managed_redis/100-simple-managed-redis/) — Basic Managed Redis instance
- [`101-managed-redis-access-policy`](../../../examples/cache/managed_redis/101-managed-redis-access-policy/) — Managed identity access-policy assignment
- [`200-managed-redis-private-endpoint`](../../../examples/cache/managed_redis/200-managed-redis-private-endpoint/) — Private endpoint and private DNS configuration
