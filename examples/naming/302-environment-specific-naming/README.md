# Example 302: Environment-Specific Naming Patterns

This example demonstrates different naming strategies for different environments using the hybrid naming system.

## Configuration

- **Development**: Passthrough naming for quick testing
- **Staging**: Local module with custom component order
- **Production**: Azurecaf with random suffix for uniqueness

## Expected Results by Environment

### Development (passthrough = true)

| Resource | Input Name       | Final Name       |
| -------- | ---------------- | ---------------- |
| chatbot  | "my-dev-chatbot" | `my-dev-chatbot` |

### Staging (local module)

| Resource   | Input Name   | Final Name                   |
| ---------- | ------------ | ---------------------------- |
| chatbot    | "chatbot"    | `stg-cog-chatbot-staging`    |
| translator | "translator" | `stg-cog-translator-staging` |

### Production (azurecaf with random)

| Resource   | Input Name   | Final Name                 |
| ---------- | ------------ | -------------------------- |
| chatbot    | "chatbot"    | `prod-cog-chatbot-8k2m`    |
| translator | "translator" | `prod-cog-translator-5r7w` |

## Usage

```bash
# Navigate to examples directory
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Test development environment
terraform_with_var_files \
  --dir /naming/302-environment-specific-naming/ \
  --action plan \
  --auto auto \
  --workspace dev \
  --var-file dev.tfvars

# Test staging environment
terraform_with_var_files \
  --dir /naming/302-environment-specific-naming/ \
  --action plan \
  --auto auto \
  --workspace staging \
  --var-file staging.tfvars

# Test production environment
terraform_with_var_files \
  --dir /naming/302-environment-specific-naming/ \
  --action plan \
  --auto auto \
  --workspace prod \
  --var-file prod.tfvars
```

## Environment-Specific Configurations

### Development Environment

```hcl
# Quick and simple names for development
global_settings = {
  environment    = "dev"
  prefix         = "dev"
  passthrough    = true  # Use exact names

  naming = {
    use_azurecaf      = false
    use_local_module  = false
  }
}
```

### Staging Environment

```hcl
# Structured naming for staging
global_settings = {
  environment    = "staging"
  prefix         = "stg"
  suffix         = "001"

  naming = {
    use_azurecaf      = false
    use_local_module  = true
    component_order   = ["prefix", "abbreviation", "name", "environment"]
  }
}
```

### Production Environment

```hcl
# Secure and unique naming for production
global_settings = {
  environment    = "prod"
  prefix         = "prod"
  random_length  = 4

  naming = {
    use_azurecaf      = true
    use_local_module  = false
  }
}
```

## Key Features

- **Environment-Specific Logic**: Different naming strategies per environment
- **Conditional Resource Deployment**: Some resources only in certain environments
- **Security Considerations**: Different settings for prod vs non-prod
- **Validation**: Environment validation to prevent mistakes

## Resource Configuration Differences

### Development

- Simple names for easy identification
- Open network access for testing
- Local authentication enabled

### Staging

- Structured naming following patterns
- Similar to production but with different prefixes
- Moderate security settings

### Production

- Random suffixes for uniqueness
- Restricted network access
- Enhanced security settings

This example is useful for:

- Understanding how to implement environment-specific naming
- Setting up different strategies for different deployment stages
- Managing security and naming consistency across environments
