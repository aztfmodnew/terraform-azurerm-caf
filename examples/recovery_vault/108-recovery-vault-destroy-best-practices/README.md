# Recovery Services Vault - Destroy Best Practices

This example demonstrates the best practices for configuring Recovery Services Vaults to ensure proper cleanup during `terraform destroy` operations.

## Key Configuration Points

### 1. Provider Features Configuration

Configure the Azure provider with appropriate features for Recovery Services:

```hcl
provider "azurerm" {
  features {
    recovery_service {
      purge_protected_items_from_vault_on_destroy             = true
      vm_backup_stop_protection_and_retain_data_on_destroy    = false
    }
    recovery_services_vaults {
      recover_soft_deleted_backup_protected_vm = false
    }
  }
}
```

### 2. Vault Configuration

- **Keep soft delete enabled**: AzureRM 5.8 no longer exposes a setting to disable it on this resource. The module accepts omitted or true legacy values and rejects false rather than silently ignoring it.
- **Configure timeouts**: Add appropriate timeout values for delete operations

### 3. Common Destroy Issues and Solutions

#### Issue: Vault cannot be deleted due to protected items

**Solution**: Enable `purge_protected_items_from_vault_on_destroy = true` in provider features

#### Issue: Vault stuck in soft-deleted state

**Solution**: Inspect the vault's protected and soft-deleted items. Retention and service restrictions can prevent immediate deletion; do not bypass them by removing resources from Terraform state.

#### Issue: Backup protected VMs blocking deletion

**Solution**: Configure backup protection behavior in provider features

## Example Usage

See the configuration files in this directory for a complete working example that implements these best practices.

## Testing

This example creates a vault and backup policy, but does not protect a VM or
test deletion of existing backup data. Provider purge settings can destroy
backup data and must not be copied into production without review.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/recovery_vault/108-recovery-vault-destroy-best-practices/configuration.tfvars \
  -verbose
```

The focused compatibility test accepts omitted/true legacy settings and
expects a failure for `soft_delete_enabled = false`:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/azurerm_5_8
terraform -chdir=examples test -test-directory=tests/azurerm_5_8 \
  -filter=tests/azurerm_5_8/recovery_vault.tftest.hcl -no-color
```
