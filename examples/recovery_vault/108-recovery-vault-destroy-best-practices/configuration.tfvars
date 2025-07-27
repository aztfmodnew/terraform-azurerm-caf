global_settings = {
  regions = {
    region1 = "australiaeast"
  }
}

# Provider features configuration for optimal destroy behavior
provider_azurerm_features_recovery_service = {
  # Purge all protected items when destroying the vault
  purge_protected_items_from_vault_on_destroy = true
  # Stop protection without retaining data for VMs
  vm_backup_stop_protection_and_retain_data_on_destroy = false
  # Don't suspend protection - delete immediately
  vm_backup_suspend_protection_and_retain_data_on_destroy = false
}

provider_azurerm_features_recovery_services_vault = {
  # Don't recover soft deleted backup protected VMs
  recover_soft_deleted_backup_protected_vm = false
}

resource_groups = {
  primary = {
    name = "rg-recovery-vault-destroy-test"
    region = "region1"
  }
}

recovery_vaults = {
  test_vault = {
    name               = "vault-destroy-test"
    resource_group_key = "primary"
    region             = "region1"
    
    # Disable soft delete for immediate destruction in test environments
    soft_delete_enabled = false
    
    # Configure custom timeouts for destroy operations
    timeouts = {
      create = "60m"
      update = "30m" 
      delete = "60m"
    }

    backup_policies = {
      vms = {
        test_policy = {
          name      = "TestVMBackupPolicy"
          vault_key = "test_vault"
          rg_key    = "primary"
          timezone  = "UTC"
          backup = {
            frequency = "Daily"
            time      = "02:00"
          }
          retention_daily = {
            count = 7
          }
        }
      }
    }
  }
}
