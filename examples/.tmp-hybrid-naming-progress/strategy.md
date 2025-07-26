# Hybrid Naming Strategy

## Rules:

### For modules that ALREADY have azurecaf implemented:

- ✅ Implement hybrid naming system in module (add naming.tf)
- ❌ DO NOT modify tfvars (leave them as-is)

### For modules that DO NOT have azurecaf implemented:

- ✅ Implement hybrid naming system in module (add naming.tf)
- ✅ Add to tfvars: `naming = { use_azurecaf = false, use_local_module = true }`

## Progress:

### Completed:

- ✅ storage_accounts (had azurecaf) - module updated with hybrid naming, tfvars left as-is
- ✅ cognitive_services/cognitive_services_account (had azurecaf) - module updated with hybrid naming, tfvars left as-is
- ✅ compute/container_app_environment (had azurecaf) - module already has hybrid naming, tfvars left as-is

### Currently working on:

- 🔄 Looking for next module to process
