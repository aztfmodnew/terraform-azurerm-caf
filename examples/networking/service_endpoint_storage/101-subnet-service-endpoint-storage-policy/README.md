# Azure Subnet Service Endpoint Storage Policy Example

This example demonstrates how to create and configure Azure Subnet Service Endpoint Storage Policies using the CAF Terraform module.

## Overview

Service endpoint policies allow you to filter virtual network traffic to Azure services over service endpoints. This example shows how to:

1. Create a virtual network with subnets that have service endpoints enabled
2. Configure storage accounts with network access rules
3. Create service endpoint policies to control access to specific storage accounts
4. Associate policies with subnets to enforce access control

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network                          │
│                   (10.100.0.0/16)                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Storage Subnet                         │    │
│  │             (10.100.1.0/24)                         │    │
│  │                                                     │    │
│  │  Service Endpoints: [Microsoft.Storage]             │    │
│  │  Service Endpoint Policy: storage_policy            │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Service Endpoint
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Azure Storage                               │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │ Allowed Storage │    │    Restricted Storage           │ │
│  │ (accessible)    │    │    (blocked by policy)          │ │
│  └─────────────────┘    └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Configuration Files

### Configuration Variables

The example uses the following key configuration sections:

- **`global_settings`**: Standard CAF global settings with naming conventions
- **`vnets`**: Virtual network configuration with address space
- **`virtual_subnets`**: Subnet configuration with service endpoints enabled
- **`storage_accounts`**: Storage accounts with network access rules
- **`subnet_service_endpoint_storage_policies`**: Service endpoint policy definitions

### Service Endpoint Policy Structure

```hcl
subnet_service_endpoint_storage_policies = {
  storage_policy = {
    name               = "storage-access-policy"
    resource_group_key = "networking_rg"
    
    definitions = {
      allowed_storage_def = {
        name        = "AllowedStorageDefinition"
        description = "Policy definition allowing access to specific storage accounts"
        service     = "Microsoft.Storage"
        service_resources = [
          # Storage account resource IDs that should be accessible
        ]
      }
    }
  }
}
```

## Service Endpoint Policies Explained

### What are Service Endpoint Policies?

Service endpoint policies provide granular access control for Azure service traffic from your virtual network over service endpoints. They allow you to:

- **Allow traffic** only to specific Azure service resources
- **Deny traffic** to all other resources of the same service type
- **Audit traffic** flowing over service endpoints

### Benefits

1. **Enhanced Security**: Restrict access to only approved storage accounts
2. **Data Exfiltration Protection**: Prevent unauthorized data transfer to external storage
3. **Compliance**: Meet regulatory requirements for data access control
4. **Monitoring**: Audit and monitor access patterns

### Supported Services

Currently, service endpoint policies support:
- **Microsoft.Storage**: Azure Storage accounts (Blobs, Files, Queues, Tables)

## Usage Instructions

1. **Deploy the Infrastructure**:
   ```bash
   cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples
   terraform_with_var_files --dir /networking/101-subnet-service-endpoint-storage-policy/ --action plan --auto auto --workspace example
   terraform_with_var_files --dir /networking/101-subnet-service-endpoint-storage-policy/ --action apply --auto auto --workspace example
   ```

2. **Verify the Deployment**:
   - Check that the virtual network and subnet are created with service endpoints
   - Confirm storage accounts are created with appropriate network rules
   - Validate that the service endpoint policy is associated with the subnet

3. **Test Access Control**:
   - Deploy a VM in the subnet with service endpoint policy
   - Attempt to access the allowed storage account (should succeed)
   - Attempt to access a restricted storage account (should be blocked)

## Important Considerations

### Policy Association

Service endpoint policies must be associated with subnets that have the corresponding service endpoints enabled:

```hcl
virtual_subnets = {
  storage_subnet = {
    service_endpoints = ["Microsoft.Storage"]
    service_endpoint_policy_ids = [
      # Reference to the policy ID
    ]
  }
}
```

### Storage Account Configuration

Storage accounts should be configured with network rules to work with service endpoints:

```hcl
storage_accounts = {
  example_storage = {
    network_rules = {
      default_action = "Deny"
      virtual_network_subnet_ids = [
        # Subnet IDs that should have access
      ]
    }
  }
}
```

### Resource ID Format

Service resources in policy definitions must use the full Azure resource ID format:
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Storage/storageAccounts/{storage-account-name}
```

## Security Best Practices

1. **Principle of Least Privilege**: Only allow access to storage accounts that are absolutely necessary
2. **Regular Audits**: Periodically review and update service endpoint policies
3. **Network Segmentation**: Use different subnets for different application tiers
4. **Monitoring**: Enable diagnostic logging for service endpoints and policies
5. **Testing**: Thoroughly test access patterns before deploying to production

## Cleanup

To remove all resources:

```bash
terraform_with_var_files --dir /networking/101-subnet-service-endpoint-storage-policy/ --action destroy --auto auto --workspace example
```

## References

- [Azure Service Endpoints Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)
- [Service Endpoint Policies Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoint-policies-overview)
- [CAF Terraform Module Documentation](https://github.com/Azure/terraform-azurerm-caf)

## Related Examples

- VNet Service Endpoints: `examples/networking/virtual_network`
- Storage Network Rules: `examples/storage/storage_accounts`
- Network Security Groups: `examples/networking/network_security_groups`
