# AzureRM 5.8 migration notes

This guide records the compatibility changes and migration actions associated
with upgrading the CAF framework to AzureRM `~> 5.8.0`. It is maintained
separately from `CHANGELOG.md`, which is generated during releases.

## Compatibility changes

- Root and examples provider requirements now target AzureRM `~> 5.8.0`.
- Legacy settings remain supported for renamed APIM certificate, HTTP/2 and TLS
  fields; load-balancer networking flags; gateway BGP; NetApp export protocols;
  Data Factory pipeline metrics and linked services; SQL email alerts; VM/VMSS
  networking, disks and upgrades; and Event Grid endpoint references. Current
  input names take precedence over legacy aliases.
- Legacy Cosmos DB `local_authentication_disabled` and VMSS
  `disable_automatic_rollback` values are inverted when mapped to the
  corresponding enabled flags. Cosmos DB primary-key outputs and aggregate
  outputs are marked sensitive; consuming root outputs must also declare
  `sensitive = true`.
- Container App custom-domain verification and aggregate outputs are marked
  sensitive to match the provider's sensitivity annotation.
- Kusto language extensions supplied as a legacy single object or collection
  remain supported. Legacy Front Door actions, conditions and negation map to
  the current nested schema.
- The required AKS node-provisioning profile uses the documented `Manual`
  default; kubelet and Linux configuration aliases remain supported.
- Storage customer-managed keys resolve as Key Vault key URIs. Existing
  key-name/reference and version settings remain supported. Omitted, null or
  empty versions produce a versionless URI; explicit versions remain pinned.
- Mocked compatibility assertions and representative APIM, Data Factory,
  NetApp, Application Gateway and AI Services examples validate without
  deploying Azure resources.

## Required migration actions

### Recovery Services Vaults

AzureRM 5.8 no longer exposes `soft_delete_enabled`. The setting is omitted
from VM backup examples, and legacy `false` is rejected rather than silently
ignored. The deprecated compatibility output returns the constant `true`; it
does not report the actual Azure configuration. Omitting the setting does not
bypass Azure soft-delete retention during live cleanup.

### AI Services

The examples-level `moved` block only moves the module wrapper address. Changing
from `azurerm_ai_services` to `azurerm_cognitive_account` requires the separate
state/import procedure described in the [AI Services README](../../examples/ai_services/README.md).
Do not apply a destroy/recreate plan for an existing account. The former
project-management default is preserved, and legacy `managed_hsm_key_id` is
rejected explicitly.

### Key Vault contacts

Keep the existing `settings.contacts` map. Contacts are now managed with
`azurerm_key_vault_certificate_contacts` rather than an inline block. For
existing contacts, back up state and import them at
`module.keyvaults["<key>"].azurerm_key_vault_certificate_contacts.contacts["contacts"]`;
examples add the `module.example.` prefix.

The import ID is
`https://<vault>.vault.azure.net/certificates/contacts`, not the vault ARM ID.
A `moved` block cannot extract an inline block into a resource. Grant
`ManageContacts` certificate permissions before managing contacts, then inspect
the resulting plan.

### Linux Web Apps and slots

Native `ruby_version` is no longer supported. Configure a custom container
instead; legacy Ruby configuration fails with an explicit migration message.

### Container Apps

Per-probe `termination_grace_period_seconds` is no longer supported. It is
rejected explicitly rather than silently moved to template scope, which would
change its meaning. Configure the template-level grace period intentionally.
