# Storage Account Network Disruption via NSG

This example demonstrates how to use Azure Chaos Studio to test application resilience to network disruptions affecting Azure Storage access.

## Overview

This configuration:
1. Creates a virtual network with subnet and NSG
2. Creates a storage account with network rules allowing access from the subnet
3. Enables Chaos Studio target on the NSG
4. Adds the SecurityRule capability
5. Creates an experiment that blocks storage access by injecting a Deny rule

## Features Demonstrated

- **Network Security Testing**: Simulates storage outage via NSG rule injection
- **Service Disruption**: Tests application behavior when storage becomes unreachable
- **Temporary Rule Injection**: Chaos Studio adds/removes NSG rules automatically
- **Non-Destructive Testing**: No data loss, only network-level blocking
- **Managed Identity**: Uses user-assigned identity for experiment execution

## Prerequisites

- Azure subscription
- Permission to create managed identities and role assignments
- Chaos Studio enabled in your subscription

## Important Notes

### How It Works

1. **Initial State**: NSG has an Allow rule for storage access on port 443
2. **During Experiment**: Chaos Studio injects a **Deny** rule with higher priority (90 < 100)
3. **Effect**: All HTTPS traffic to Azure Storage from the subnet is blocked
4. **After Experiment**: Chaos Studio automatically removes the injected rule

### NSG Security Rule Parameters

Key parameters in the experiment:
- **name**: "Block_Storage_Access" (unique name for injected rule)
- **priority**: 90 (higher priority than existing Allow rule at 100)
- **direction**: "Outbound" (blocks outbound connections)
- **access**: "Deny" (blocks traffic)
- **protocol**: "Tcp"
- **sourceAddresses**: ["10.0.1.0/24"] (subnet CIDR)
- **destinationAddresses**: ["Storage"] (Azure Storage service tag)
- **destinationPortRanges**: ["443"] (HTTPS)

### Storage Account Network Rules

The storage account is configured with:
- **default_action = "Deny"**: Blocks all traffic by default
- **virtual_network_subnet_ids**: Allows access from test subnet
- This creates dependency on the subnet's NSG rules

## Testing Scenarios

### Scenario 1: Test Application Retry Logic

Deploy an application in the VNet that accesses the storage account:
1. Start experiment to block storage
2. Application should detect connection failures
3. Application should retry with exponential backoff
4. After experiment ends, application should recover

### Scenario 2: Test Circuit Breaker Pattern

For applications with circuit breaker:
1. Start experiment
2. Circuit breaker should open after threshold failures
3. Application should use fallback mechanism
4. After experiment, circuit breaker should close automatically

## Testing

### Mock Test (Syntax Validation)

```bash
cd examples
terraform init -upgrade
terraform test \
  -test-directory=./tests/mock \
  -var-file=./chaos_studio/400-storage-nsg-block/configuration.tfvars \
  -verbose
```

### Deploy to Azure

```bash
cd examples

# Plan
terraform_with_var_files \
  --dir /chaos_studio/400-storage-nsg-block/ \
  --action plan \
  --auto auto \
  --workspace test

# Apply
terraform_with_var_files \
  --dir /chaos_studio/400-storage-nsg-block/ \
  --action apply \
  --auto auto \
  --workspace test
```

### Execute Experiment

After deployment:

```bash
# Get experiment ID
EXPERIMENT_ID=$(az resource show \
  --resource-group <resource-group-name> \
  --name storage-nsg-block-experiment \
  --resource-type Microsoft.Chaos/experiments \
  --query id -o tsv)

# Start experiment (blocks storage for 5 minutes)
az rest --method post \
  --url "${EXPERIMENT_ID}/start?api-version=2024-01-01"

# Monitor status
az rest --method get \
  --url "${EXPERIMENT_ID}/executions?api-version=2024-01-01"
```

### Verify Blocking

From a VM in the subnet:

```bash
# Before experiment - should succeed
curl -I https://<storage-account>.blob.core.windows.net/

# During experiment - should timeout
curl -I https://<storage-account>.blob.core.windows.net/ --max-time 10

# After experiment - should succeed again
curl -I https://<storage-account>.blob.core.windows.net/
```

### Check NSG Rules

```bash
# During experiment - verify injected rule exists
az network nsg rule list \
  --resource-group <resource-group-name> \
  --nsg-name storage-chaos-nsg \
  --query "[?name=='Block_Storage_Access']"

# After experiment - verify rule is removed
az network nsg rule list \
  --resource-group <resource-group-name> \
  --nsg-name storage-chaos-nsg \
  --query "[?name=='Block_Storage_Access']"
```

## Known Limitations

1. **Existing Connections**: The NSG fault only affects NEW connections. Existing active TCP connections persist for ~4 minutes of idle time.
   
   **Workaround**: Combine with other faults to force connection reset:
   - VM Shutdown (if testing from VM)
   - Kill Process fault (agent-based)
   - Stop Service fault (agent-based)

2. **Priority Conflicts**: The injected rule priority (90) must be unique. If another rule exists with priority 90, the experiment fails.

3. **ASG Not Supported**: Application Security Groups (ASG) are not supported as source/destination.

4. **flushConnection Parameter**: The SecurityRule-1.1 capability has a `flushConnection` parameter, but it currently has a known issue that may cause errors. Use version 1.0 instead.

## Cleanup

```bash
terraform_with_var_files \
  --dir /chaos_studio/400-storage-nsg-block/ \
  --action destroy \
  --auto auto \
  --workspace test
```

## Cost Estimate

Approximate monthly costs (West Europe):
- Virtual Network: Free
- NSG: Free
- Storage Account (LRS, minimal usage): ~$0.50/month
- Chaos Studio experiments: Free (up to 100 experiments/month)
- Managed Identity: Free

**Total: ~$0.50/month**

## Extensions

### Test with Agent-Based Faults

Combine NSG fault with agent-based faults for more realistic scenarios:

```hcl
# Add VM with Chaos Agent
virtual_machines = {
  test_vm = {
    # ... VM configuration
  }
}

# Install Chaos Agent extension
vm_extensions = {
  chaos_agent = {
    # ... agent configuration
  }
}

# Add parallel branches in experiment
steps = [
  {
    name = "CombinedDisruption"
    branch = [
      {
        name = "NetworkBlock"
        actions = [
          {
            # NSG Security Rule fault
          }
        ]
      },
      {
        name = "ProcessKill"
        actions = [
          {
            # Kill Process fault on VM
          }
        ]
      }
    ]
  }
]
```

## References

- [Azure Chaos Studio Documentation](https://learn.microsoft.com/azure/chaos-studio/)
- [NSG Security Rule Capability](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library#nsg-security-rule)
- [Network Security Groups Overview](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Storage Account Network Rules](https://learn.microsoft.com/azure/storage/common/storage-network-security)
