virtual_machines = {
  winvm1 = {
    resource_group_key = "rg"
    os_type            = "windows"
    size               = "Standard_DS1_v2"
    virtual_machine_settings = {
      windows = {
        name                   = "winvm1"
        size                   = "Standard_DS1_v2"
        admin_username         = "azureuser"
        admin_password         = "P@ssw0rd1234!"
        patch_mode             = "AutomaticByOS"
        network_interface_keys = ["winvm1_nic0"]
        os_disk = {
          name                 = "winvm1-os"
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }
        source_image_reference = {
          publisher = "MicrosoftWindowsServer"
          offer     = "WindowsServer"
          sku       = "2019-Datacenter"
          version   = "latest"
        }
        tags = {
          role = "vm1"
        }
      }
    }
    networking_interfaces = {
      winvm1_nic0 = {
        vnet_key   = "vnet_aadds_re1"
        subnet_key = "vms"
        name       = "winvm1-0"
      }
    }
  }
  winvm2 = {
    resource_group_key = "rg"
    os_type            = "windows"
    size               = "Standard_DS1_v2"
    virtual_machine_settings = {
      windows = {
        name                   = "winvm2"
        size                   = "Standard_DS1_v2"
        admin_username         = "azureuser"
        admin_password         = "P@ssw0rd1234!"
        patch_mode             = "AutomaticByOS"
        network_interface_keys = ["winvm2_nic0"]
        os_disk = {
          name                 = "winvm2-os"
          caching              = "ReadWrite"
          storage_account_type = "Standard_LRS"
        }
        source_image_reference = {
          publisher = "MicrosoftWindowsServer"
          offer     = "WindowsServer"
          sku       = "2019-Datacenter"
          version   = "latest"
        }
        tags = {
          role = "vm2"
        }
      }
    }
    networking_interfaces = {
      winvm2_nic0 = {
        vnet_key   = "vnet_aadds_re1"
        subnet_key = "vms"
        name       = "winvm2-0"
      }
    }
  }
}
