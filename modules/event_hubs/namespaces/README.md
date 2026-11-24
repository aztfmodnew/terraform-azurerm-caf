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
`identity.managed_identity_keys` and `identity.remote`.

Outputs expose the namespace ID, name, location, tags, principal and tenant IDs,
child hubs, and sanitized child authorization-rule metadata.
