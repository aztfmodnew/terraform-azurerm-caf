# Azure Chaos Studio Examples

This directory contains **validated and officially supported** Azure Chaos Studio examples based on the [Azure Chaos Studio Fault Library](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library).

## ✅ Available Examples

All examples in this directory use **officially documented** Chaos Studio capabilities and have been validated against Microsoft's fault library.

### [300-cosmosdb-failover](./300-cosmosdb-failover/)
**Tests Cosmos DB regional failover scenarios**

- **Capability**: `Failover-1.0` (officially supported for Cosmos DB)
- **Target Type**: `Microsoft-CosmosDB`
- **Use Case**: Database regional outage and automatic failover testing
- **Features**:
  - Multi-region Cosmos DB (West Europe + North Europe)
  - Automatic failover enabled
  - Simulates primary region failure
  - Tests application resilience to database failover

**Cost Estimate**: ~$48/month (2 regions, 400 RU/s)

---

### [400-storage-nsg-block](./400-storage-nsg-block/)
**Tests storage resilience via network disruption**

- **Capability**: `SecurityRule-1.0` (officially supported for NSG)
- **Target Type**: `Microsoft-NetworkSecurityGroup`
- **Use Case**: Storage access disruption and application retry logic testing
- **Features**:
  - VNet with NSG and subnet
  - Storage account with network rules
  - Temporary NSG rule injection to block storage access
  - Non-destructive (no data loss)
  - Tests circuit breaker and retry patterns

**Cost Estimate**: ~$0.50/month (minimal infrastructure)

---

## 📋 Prerequisites

All examples require:
- Azure subscription with sufficient quota
- Permission to create managed identities and role assignments
- Chaos Studio enabled in your subscription (automatically enabled on first use)
- Azure CLI or Terraform authenticated to Azure

## 🚀 Quick Start

### 1. Mock Test (Syntax Validation)

Validate configuration syntax without deploying resources:

```bash
cd examples
terraform init -upgrade
terraform test \
  -test-directory=./tests/mock \
  -var-file=./tests/chaos_studio/100-simple-chaos-target-mock/configuration.tfvars \
  -verbose
```

### 2. Deploy Example

Choose an example and deploy:

```bash
cd examples

# Cosmos DB Failover
terraform_with_var_files \
  --dir /chaos_studio/300-cosmosdb-failover/ \
  --action apply \
  --auto auto \
  --workspace test

# OR Storage NSG Block
terraform_with_var_files \
  --dir /chaos_studio/400-storage-nsg-block/ \
  --action apply \
  --auto auto \
  --workspace test
```

### 3. Execute Experiment

From Azure Portal:
1. Navigate to **Chaos Studio** > **Experiments**
2. Select your experiment
3. Click **Start**
4. Monitor execution status

Or via Azure CLI:

```bash
# Get experiment resource ID
EXPERIMENT_ID=$(az resource show \
  --resource-group <resource-group-name> \
  --name <experiment-name> \
  --resource-type Microsoft.Chaos/experiments \
  --query id -o tsv)

# Start experiment
az rest --method post \
  --url "${EXPERIMENT_ID}/start?api-version=2024-01-01"

# Check execution status
az rest --method get \
  --url "${EXPERIMENT_ID}/executions?api-version=2024-01-01"
```

## 🔍 Understanding Chaos Studio

### Target Types
Chaos Studio requires you to **enable** resources as targets before running experiments:

- `Microsoft-CosmosDB` - Cosmos DB accounts
- `Microsoft-NetworkSecurityGroup` - Network Security Groups
- `Microsoft-VirtualMachine` - Virtual machines (for agent-based faults)
- `Microsoft-VirtualMachineScaleSet` - VM scale sets
- And many more...

### Capabilities
Each target type supports specific **capabilities** (fault types):

- **Failover-1.0** - For Cosmos DB (simulates regional failover)
- **SecurityRule-1.0** - For NSG (injects network rules)
- **Shutdown-1.0** - For VMs (graceful or abrupt shutdown)
- See [full fault library](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library)

### Experiments
Experiments define:
- **Selectors**: Which targets to affect
- **Steps**: Sequential phases of the experiment
- **Branches**: Parallel actions within a step
- **Actions**: The actual faults to inject

## ⚠️ Important Notes

### Capability Validation
**All capabilities used in these examples are validated against official Microsoft documentation**. If a capability is not listed in the [Azure Chaos Studio Fault Library](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library), it is NOT supported.

### Common Misconceptions

❌ **Storage Account Failover** - NOT supported in Chaos Studio
- There is NO `Failover-1.0` capability for Storage Accounts
- Use manual failover: `az storage account failover`
- Or use NSG blocking to test storage resilience (example 400)

❌ **Service-Direct vs Agent-Based** confusion
- Service-direct faults work at Azure control plane level
- Agent-based faults require VM extension installation
- Storage Accounts do NOT support agent-based faults (no compute)

### Permission Requirements

Managed identities used by experiments need:
- **Contributor** role on resource group (for most operations)
- **Additional roles** for specific resources (e.g., Storage Account Contributor)

See each example's README for specific RBAC requirements.

## 📚 References

### Official Documentation
- [Azure Chaos Studio Overview](https://learn.microsoft.com/azure/chaos-studio/)
- [Chaos Studio Fault Library](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library) (authoritative source)
- [Supported Resource Types](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-providers)
- [Chaos Studio Pricing](https://azure.microsoft.com/pricing/details/chaos-studio/)

### Example-Specific Documentation
- [Cosmos DB High Availability](https://learn.microsoft.com/azure/cosmos-db/high-availability)
- [Network Security Groups](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Storage Account Network Security](https://learn.microsoft.com/azure/storage/common/storage-network-security)

## 🛠️ Troubleshooting

### Experiment Fails Immediately
- **Check**: RBAC permissions for managed identity
- **Check**: Target is properly enabled (shows as "Enabled" in portal)
- **Check**: Capability is enabled on the target

### "Capability not found" Error
- **Verify**: Capability name matches exactly (case-sensitive)
- **Verify**: Capability is supported for the target type
- **Check**: [Fault library documentation](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library)

### NSG Rule Injection Fails
- **Check**: Priority conflicts (rule priority must be unique)
- **Check**: Rule doesn't reference unsupported features (ASG)
- **Use**: Version 1.0 instead of 1.1 (known issues with flushConnection)

### Cosmos DB Failover Takes Too Long
- **Expected**: Failover takes 5-10 minutes (independent of experiment duration)
- **Note**: Cooldown period of ~10 minutes between failovers
- **Check**: readRegion parameter matches secondary region name exactly

## 🤝 Contributing

When adding new Chaos Studio examples:

1. **Validate capability exists** in [official fault library](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library)
2. **Test thoroughly** with mock tests and real deployments
3. **Document clearly** including prerequisites, limitations, and cost estimates
4. **Follow naming convention**: `XXX-description-of-scenario/`
   - 300-399: Service-direct faults
   - 400-499: Combined scenarios
5. **Include mock test configuration** in `/examples/tests/chaos_studio/`

## 📝 License

This code is part of the Azure CAF Terraform framework and follows the same license terms.

---

**Last Updated**: January 2026  
**Validated Against**: Azure Chaos Studio Fault Library (2024-01-01 API version)
