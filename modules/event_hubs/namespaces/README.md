# Event Hub Namespace

Creates an `azurerm_eventhub_namespace` with CAF naming, optional diagnostics and
private endpoints supplied by the root module, managed identities, network
rules, child hubs, and authorization rules.

The `settings` object supports the AzureRM namespace arguments `sku`, `capacity`,
`auto_inflate_enabled`, `dedicated_cluster_id`, `maximum_throughput_units`,
`local_authentication_enabled`, `public_network_access_enabled`,
`minimum_tls_version`, `identity`, `network_rulesets`, `timeouts`, tags, and
location overrides. Existing `event_hubs` and `auth_rules` maps remain supported.
Identity IDs can be supplied directly or resolved through
`identity.managed_identity_keys` and `identity.remote`. The current single
identity object and legacy keyed-map or list forms are supported.

Outputs expose the namespace ID, name, location, tags, principal and tenant IDs,
child hubs, and sanitized child authorization-rule metadata. Credential-bearing
authorization rules remain in the root `event_hub_auth_rules` and
`event_hub_namespace_auth_rules` object inventories so their sensitive outputs
are preserved without key collisions with child-local resources.
