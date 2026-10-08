# Storage CMK using a key URI

This example demonstrates the AzureRM 5.8 `customer_managed_key.key_vault_key_id`
input. Replace the illustrative URI with an existing Key Vault key URI before
deployment. This example does not create the external vault or key.

- A versionless URI (`https://<vault-host>/keys/<key-name>`) enables automatic key
  version updates. A versioned URI adds `/<version>` and pins that version.
- The direct URI takes precedence over legacy `keyvault_key`, `keyvault_key_key`,
  `key_name`, and `key_version` fields. Do not combine the two input styles.
- Enable soft delete and purge protection on the vault. Grant the storage
  identity the required key permissions (`Get`, `WrapKey`, `UnwrapKey`) before
  applying the CMK association. The new system identity cannot have permissions
  pre-granted; use a staged deployment or an existing user-assigned identity and
  configure both the account identity and CMK `user_assigned_identity_id`.
- Do not manage the same association through both the standalone CMK resource
  and an inline storage-account CMK block.

The existing [legacy example](../109-storage-account-advanced-options-cmk/configuration.tfvars)
remains unchanged and demonstrates CAF key-based references with managed keys.

Mock validation from the repository root (no external vault is contacted):

```bash
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=./storage_accounts/113-storage-account-cmk-key-uri/configuration.tfvars
```

Sources: [AzureRM 5.8 CMK schema](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/storage_account_customer_managed_key)
and [Azure Storage CMK requirements](https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-overview).
