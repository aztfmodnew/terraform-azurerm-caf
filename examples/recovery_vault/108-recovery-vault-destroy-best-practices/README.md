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
      vm_backup_suspend_protection_and_retain_data_on_destroy = false
    }
    recovery_services_vault {
      recover_soft_deleted_backup_protected_vm = false
    }
  }
}
```

### 2. Vault Configuration

- **Disable soft delete**: Set `soft_delete_enabled = false` for test environments or when immediate deletion is required
- **Configure timeouts**: Add appropriate timeout values for delete operations

### 3. Common Destroy Issues and Solutions

#### Issue: Vault cannot be deleted due to protected items

**Solution**: Enable `purge_protected_items_from_vault_on_destroy = true` in provider features

#### Issue: Vault stuck in soft-deleted state

**Solution**: Disable soft delete or wait 14 days for automatic purge

#### Issue: Backup protected VMs blocking deletion

**Solution**: Configure backup protection behavior in provider features

## Example Usage

See the configuration files in this directory for a complete working example that implements these best practices.

## Testing

To test the destroy behavior:

```bash
# Deploy
terraform apply

# Verify resources are created
az backup vault list

# Test destruction
terraform destroy

# Verify all resources are cleaned up
az backup vault list
```
