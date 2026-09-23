# Managed Redis `name_override` — Manual-Only Example

This example demonstrates preserving an exact existing Azure Managed Redis physical name with `name_override`.

## Manual-only status

This example is intentionally excluded from all CI/CD workflow matrices. The override represents an existing physical name and must be replaced with the real name of the target Managed Redis instance before use. It is documentation and static configuration validation only; it is not an Azure deployment recipe until reviewed against the target environment.

## Configuration

- Logical module name: `orders-cache`
- Exact physical name override: `redis-orders-prod-001`
- SKU: `Balanced_B3`
- Public network access: enabled
- System-assigned identity and encrypted default database enabled

`name_override` bypasses CAF-generated prefixes, suffixes, cleaning, and passthrough settings. The value must already satisfy Azure Managed Redis naming rules and does not rename an existing resource by itself.
