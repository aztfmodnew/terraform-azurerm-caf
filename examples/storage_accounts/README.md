# Azure Storage Accounts

This module is part of Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate this directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.30.0"

  # Add object as described below
}
```

CAF Terraform module is iterative by default, you can instantiate as many objects as needed, using the following structure:

```hcl
resource_to_be_created = {
  object1 = {
    #configuration details as below
  }
  object2 = {
    #configuration details as below
  }
}
```

You can review complete set of examples on the [GitHub repository](https://github.com/aztfmod/terraform-azurerm-caf/tree/main/examples/storage_accounts).

## AzureRM 5.8 customer-managed keys

The [legacy CMK example](109-storage-account-advanced-options-cmk/configuration.tfvars)
continues to support `keyvault_key`, `keyvault_key_key`, `key_name`, `lz_key` and
`key_version`. Omitted, null or empty versions select a versionless URI; an
explicit version remains pinned. Referenced key outputs are reused where
available. Explicit key names retain precedence over referenced key names.

The [direct key URI example](113-storage-account-cmk-key-uri/README.md) demonstrates
`customer_managed_key.key_vault_key_id`, which takes precedence over legacy fields.
CMK settings also accept `user_assigned_identity_id`, `federated_identity_client_id`
and `timeouts`, following the [AzureRM 5.8 schema](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/storage_account_customer_managed_key).

Legacy remote/static vault entries containing only an ARM ID require a management
plane lookup to discover their actual vault URI. This fallback uses the repository's
existing AzAPI provider, supports full cross-subscription IDs and does not assume a
public-cloud DNS suffix. Direct key URIs and managed keys do not require that lookup.
The caller needs read access to the external vault.

## Container creation

`storage_accounts.<key>.containers` creates nested containers through the storage
account's container submodule. Top-level `storage_containers` creates standalone
containers through the same submodule. The blob container data source reads an
existing container for legacy name-based blob inputs; it does not create one.

## AzureRM 5.8 queue properties

The [queue example](106-storage-account-queue/configuration.tfvars) exercises
standalone and nested queues, CORS, logging and metrics. Account IDs are wired
internally; existing `storage_account_key` inputs remain unchanged.
Direct callers of the queue submodule must supply `storage_account_id`; the
retained `storage_account_name` input alone cannot identify an ARM resource.

Queue properties now use the standalone
[AzureRM 5.8 resource](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/storage_account_queue_properties).
Existing nested configuration remains supported. Legacy metrics with
`enabled = false` omit the corresponding block; current metrics omit `enabled`
and are enabled by the presence of their block. Configure at least one active
CORS, logging or metrics block.

For existing deployments, import the new queue-properties resource at
`module.example.module.storage_accounts["<key>"].azurerm_storage_account_queue_properties.stg["queue_properties"]`
using the storage account ARM ID before applying. Remove the `module.example.`
prefix when using CAF directly. An inline block cannot be migrated with `moved`.
