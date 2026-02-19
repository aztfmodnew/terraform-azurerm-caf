global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  vm_region1 = {
    name = "example-vm-import-disk-rg"
  }
}

# Storage account that holds the source VHD blob to import.
# The VHD file must already exist at the specified source_uri before running terraform apply.
storage_accounts = {
  vhd_storage = {
    name                     = "vhdimportstorage"
    resource_group_key       = "vm_region1"
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    containers = {
      vhds = {
        name = "vhds"
      }
    }
  }
}

# Virtual machines
virtual_machines = {

  example_vm1 = {
    resource_group_key = "vm_region1"
    os_type            = "linux"
    keyvault_key       = "example_vm_rg1"

    networking_interfaces = {
      nic0 = {
        vnet_key                = "vnet_region1"
        subnet_key              = "example"
        primary                 = true
        name                    = "0"
        enable_ip_forwarding    = false
        internal_dns_name_label = "nic0"
      }
    }

    virtual_machine_settings = {
      linux = {
        name                            = "example-import-vm"
        size                            = "Standard_D2s_v3"
        admin_username                  = "adminuser"
        disable_password_authentication = true
        keyvault_key                    = "example_vm_rg1"

        os_disk = {
          name                 = "example-import-vm-os"
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }

        source_image_reference = {
          publisher = "Canonical"
          offer     = "UbuntuServer"
          sku       = "18.04-LTS"
          version   = "latest"
        }
      }
    }

    data_disks = {
      # Disk imported from an existing VHD blob in an Azure Storage Account.
      # The storage account is referenced by key from the storage_accounts defined above.
      # The VHD blob must exist at source_uri before terraform apply.
      imported_data1 = {
        name                 = "example-imported-data1"
        storage_account_type = "Standard_LRS"
        create_option        = "Import"
        # source_uri is the full URL of the VHD blob to import.
        # Replace with the actual blob URL from your storage account.
        source_uri          = "https://vhdimportstorage.blob.core.windows.net/vhds/data-disk.vhd"
        # storage_account_key references the storage account defined in this file.
        # Alternatively, use storage_account_id with a full resource ID for pre-existing storage accounts:
        #   storage_account_id = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<name>"
        storage_account_key = "vhd_storage"
        # disk_size_gb is optional for Import; Azure derives the size from the VHD.
        # Uncomment and set if you need to provision a larger disk than the source VHD.
        # disk_size_gb = "128"
        lun     = 1
        caching = "None"
      }
    }

  }
}

vnets = {
  vnet_region1 = {
    resource_group_key = "vm_region1"
    vnet = {
      name          = "example-vnet"
      address_space = ["10.10.100.0/24"]
    }
    specialsubnets = {}
    subnets = {
      example = {
        name = "example-subnet"
        cidr = ["10.10.100.0/25"]
      }
    }
  }
}

keyvaults = {
  example_vm_rg1 = {
    name               = "vmimportsecrets"
    resource_group_key = "vm_region1"
    sku_name           = "standard"
    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
      }
    }
  }
}
