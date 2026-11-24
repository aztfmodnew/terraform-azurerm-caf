# Event Hub

Creates an `azurerm_eventhub` using a structured `namespace` reference, a direct
namespace ID, or the legacy namespace name and resource-group lookup.

The `settings` object supports partition count, message retention, status,
`retention_description`, `capture_description`, child authorization rules, and
timeouts. Capture destinations accept the existing storage-account reference and
AzureRM 5.14 `storage_authentication_type` and `storage_authentication_id`
settings.

Outputs expose the hub ID, name, namespace ID, partition IDs, status, and
sanitized child authorization-rule metadata.
