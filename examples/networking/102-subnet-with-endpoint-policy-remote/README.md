# Subnet with Service Endpoint Policy (Remote Objects)

This example demonstrates how to create subnets with service endpoint storage policies using different approaches for referencing the policies.

## Architecture

- Virtual Network with subnets
- Service Endpoint Storage Policy
- Storage Account for testing
- Subnet associations with service endpoint policies

## Service Endpoint Policy Reference Methods

### Method 1: Using Remote Objects (Recommended)

```hcl
virtual_subnets = {
  storage_subnet = {
    name = "storage-subnet"
    cidr = ["10.0.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    
    # Reference policy by key through remote_objects
    service_endpoint_policies = ["storage_policy"]
    
    vnet = {
      key = "main_vnet"
    }
  }
}
```

### Method 2: Using Direct IDs

```hcl
virtual_subnets = {
  direct_subnet = {
    name = "direct-subnet"
    cidr = ["10.0.2.0/24"]
    service_endpoints = ["Microsoft.Storage"]
    
    # Direct policy IDs
    service_endpoint_policy_ids = [
      "/subscriptions/.../providers/Microsoft.Network/serviceEndpointPolicies/policy-name"
    ]
    
    vnet = {
      key = "main_vnet"
    }
  }
}
```

## Features Demonstrated

1. **Service Endpoint Policy Creation**: Creates policies that control which storage accounts can be accessed
2. **Remote Object References**: Shows how to reference policies using keys instead of hardcoded IDs
3. **Cross-Landing Zone Support**: Supports referencing policies from different landing zones
4. **Flexible Configuration**: Supports both direct IDs and remote object patterns

## Resolution Logic

The subnet module uses the following resolution logic:

1. If `service_endpoint_policy_ids` is provided → use direct IDs
2. If `service_endpoint_policies` is provided → resolve through remote_objects
3. Supports cross-landing zone references with `service_endpoint_policy_lz_key`

## Security Benefits

- **Network Segmentation**: Controls which storage accounts can be accessed from specific subnets
- **Zero Trust**: Implements fine-grained access control at the network level
- **Compliance**: Helps meet regulatory requirements for data access control

## Usage

```bash
terraform_with_var_files --dir networking/102-subnet-with-endpoint-policy-remote/ --action plan --auto auto --workspace example
```
