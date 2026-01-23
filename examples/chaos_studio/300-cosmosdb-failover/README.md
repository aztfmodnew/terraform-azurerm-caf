# Cosmos DB Failover Experiment

This example demonstrates how to use Azure Chaos Studio to test Cosmos DB failover scenarios.

## Overview

This configuration:
1. Creates a Cosmos DB account with multi-region replication (West Europe + North Europe)
2. Enables Chaos Studio target on the Cosmos DB account
3. Adds the Failover capability
4. Creates an experiment that triggers a failover from primary to secondary region

## Features Demonstrated

- **Cosmos DB Multi-Region Setup**: Configures automatic failover with two regions
- **Chaos Studio Integration**: Properly configures target and capability
- **Failover Testing**: Simulates regional outage by forcing failover to read region
- **Managed Identity**: Uses user-assigned identity for experiment execution
- **RBAC**: Configures Contributor role for experiment identity

## Prerequisites

- Azure subscription with sufficient quota for Cosmos DB
- Permission to create managed identities and role assignments
- Chaos Studio enabled in your subscription

## Important Notes

### Cosmos DB Configuration

The Cosmos DB account MUST have:
- **Multiple geo-locations** configured (at least 2 regions)
- **Automatic failover enabled** (`enable_automatic_failover = true`)
- One region designated as primary (failover_priority = 0)
- At least one secondary region (failover_priority = 1+)

### Failover Parameters

The `readRegion` parameter in the experiment MUST:
- Match the **display name** shown in Azure Portal (e.g., "North Europe", not "northeurope")
- Be a configured secondary region (not the primary)
- Have failover priority > 0

### Known Limitations

1. **Failover Duration**: Actual failover takes 5-10 minutes, independent of experiment duration
2. **Cooldown Period**: After failover, Cosmos DB requires ~10 minutes before next failover
3. **Data Loss**: Potential for minor data loss during failover (depending on consistency level)
4. **Cost**: Multi-region Cosmos DB has higher costs due to geo-replication

## Testing

### Mock Test (Syntax Validation)

```bash
cd examples
terraform init -upgrade
terraform test \
  -test-directory=./tests/mock \
  -var-file=./tests/chaos_studio/100-simple-chaos-target-mock/configuration.tfvars \
  -verbose
```

### Deploy to Azure

```bash
cd examples

# Plan
terraform_with_var_files \
  --dir /chaos_studio/300-cosmosdb-failover/ \
  --action plan \
  --auto auto \
  --workspace test

# Apply
terraform_with_var_files \
  --dir /chaos_studio/300-cosmosdb-failover/ \
  --action apply \
  --auto auto \
  --workspace test
```

### Execute Experiment

After deployment, execute the experiment from Azure Portal:
1. Navigate to Chaos Studio > Experiments
2. Find "cosmosdb-failover-experiment"
3. Click "Start experiment"
4. Monitor failover in Cosmos DB > Failover page

Or via Azure CLI:

```bash
# Get experiment ID
EXPERIMENT_ID=$(az resource show \
  --resource-group <resource-group-name> \
  --name cosmosdb-failover-experiment \
  --resource-type Microsoft.Chaos/experiments \
  --query id -o tsv)

# Start experiment
az rest --method post \
  --url "${EXPERIMENT_ID}/start?api-version=2024-01-01"

# Check status
az rest --method get \
  --url "${EXPERIMENT_ID}/executions?api-version=2024-01-01"
```

### Verify Failover

```bash
# Check current write region
az cosmosdb show \
  --name <cosmos-account-name> \
  --resource-group <resource-group-name> \
  --query writeLocations[0].locationName -o tsv
```

## Cleanup

```bash
terraform_with_var_files \
  --dir /chaos_studio/300-cosmosdb-failover/ \
  --action destroy \
  --auto auto \
  --workspace test
```

## Cost Estimate

Approximate monthly costs (West Europe):
- Cosmos DB (2 regions, 400 RU/s): ~$48/month
- Chaos Studio experiments: Free (up to 100 experiments/month)
- Managed Identity: Free

## References

- [Azure Chaos Studio Documentation](https://learn.microsoft.com/azure/chaos-studio/)
- [Cosmos DB Failover Capability](https://learn.microsoft.com/azure/chaos-studio/chaos-studio-fault-library#cosmos-db-failover)
- [Cosmos DB High Availability](https://learn.microsoft.com/azure/cosmos-db/high-availability)
