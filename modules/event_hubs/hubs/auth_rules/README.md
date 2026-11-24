# Event Hub Authorization Rule

Creates an `azurerm_eventhub_authorization_rule`. Existing `rule_name`,
`listen`, `send`, and `manage` settings are preserved; optional timeouts are
supported.

Outputs expose the ID and rule name. Connection strings and keys are explicitly
marked sensitive.
