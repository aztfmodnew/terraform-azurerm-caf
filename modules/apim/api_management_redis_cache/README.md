# API Management external Redis cache

Creates `azurerm_api_management_redis_cache`, exposing all official AzureRM
**5.9.0** arguments and timeouts. It registers a cache; it does not provision Redis.

## Inputs

| Input | Type | Required/default |
|---|---|---|
| `global_settings` | any | Required; CAF naming |
| `client_config` | any | Required; current `landingzone_key` |
| `settings` | object | Required; [typed contract](variables.tf) |
| `remote_objects` | any | `{}`; `api_management` and optional `redis_caches` |
| `base_tags` | bool | `false`; child has no Azure tags |

Required: `name`, a resolvable connection string and `api_management_id`.
APIM resolves direct ID, `api_management.id`, then alias key/lz_key.
Optional: `description`, `cache_location` (default `default`, also accepts an
Azure region), `redis_cache_id`, `timeouts`. Explicit null cache_location uses
the same default.

Backing cache ID resolves direct `redis_cache_id`, `redis_cache.id`, then
`remote_objects.redis_caches[lz_key][key].id`. It can be omitted entirely.
All references default null/omitted lz_key to the client landing zone.
Supply `settings.connection_string` directly, or omit it and resolve
`remote_objects.redis_caches[lz_key][key].primary_connection_string` through
`redis_cache.key`. A direct string takes precedence over that managed output.
Either a direct connection string or a cache key exposing that output is
required; the module validates that a source is provided.
The connection string is marked sensitive at the resource boundary and is
never exported, but is still stored in state. Supply it securely; do not commit
access keys or use an ordinary plan output as a secret store.

Exact public CAF type: `azurerm_api_management_redis_cache`; global naming flags
including passthrough apply. Timeout defaults: create/update/delete 30m, read
5m. No fake child location, tags, diagnostic or private-endpoint blocks.
`cache_location` is an APIM cache-selection setting, not a resource location.

## Outputs and example

`id`: APIM cache ARM ID; `name`: generated name; `redis_cache_id`: optional backing ID.
See [146-api_management_redis_cache](../../../examples/apim/146-api_management_redis_cache).
It provisions both APIM and Redis and resolves the real managed connection
string by key. Configure APIM cache policies separately.

## Mock contract

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_redis_cache
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_redis_cache -no-color
```

Use Terraform >=1.9, AzureRM 5.9.0 and AzureCAF from the root. Both providers are
mocked; plan assertions cover optional/local/remote/direct cache IDs, parent
precedence, defaults/nulls, connection-string forwarding and timeouts. No Redis
authentication, network connectivity or Azure cache behavior is tested.
