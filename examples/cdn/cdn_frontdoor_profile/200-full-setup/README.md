# CDN Front Door Profile - Full Setup Example

This example demonstrates a complete CDN Front Door Profile setup with:

- **Resource Groups**: Basic resource group configuration
- **Key Vault**: Key vault with certificates for SSL/TLS
- **Managed Identity**: Identity for CDN to access Key Vault
- **RBAC**: Role assignments for proper permissions
- **CDN Front Door Profile**: Complete profile with endpoints, origins, rules, and custom domains

## Architecture Components

### 1. Resource Groups (`resource_groups.tfvars`)

- Main resource group for all CDN Front Door resources

### 2. Key Vault & Certificates (`keyvaults.tfvars`)

- Key Vault for storing SSL certificates
- Self-signed certificate for demonstration
- Access policies for user and managed identity

### 3. Managed Identity & RBAC (`managed_identities.tfvars`)

- User-assigned managed identity for CDN Front Door
- Role assignments for Key Vault access:
  - Key Vault Secrets User
  - Key Vault Certificate User

### 4. CDN Front Door Profile (`configuration.tfvars`)

- Premium SKU Front Door Profile
- Custom domains with SSL certificates
- Origin groups and origins
- Rule sets and routing rules
- Secrets referencing Key Vault certificates

## Usage

Navigate to the examples directory and run:

```bash
# Initialize Terraform
terraform init

## Deployment Options

This example supports two Key Vault authorization approaches:

### Option 1: Access Policies (Default - Simpler)

If you encounter permission issues with RBAC, use traditional access policies:

1. In `keyvaults.tfvars`, comment out or set: `# enable_rbac_authorization = true`
2. Run without `role_mapping.tfvars`:

```bash
# Plan without role_mapping.tfvars
terraform plan \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/resource_groups.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/keyvaults.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/managed_identities.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/configuration.tfvars

# Apply without role_mapping.tfvars
terraform apply \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/resource_groups.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/keyvaults.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/managed_identities.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/configuration.tfvars
```

### Option 2: RBAC (Recommended - More Secure)

For RBAC-based authorization with Azure built-in roles:

1. In `keyvaults.tfvars`, ensure: `enable_rbac_authorization = true`
2. Include `role_mapping.tfvars` in all commands:

```bash
# Plan with all configuration files including RBAC
terraform plan \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/resource_groups.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/keyvaults.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/managed_identities.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/role_mapping.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/configuration.tfvars

# Apply with all configuration files including RBAC
terraform apply \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/resource_groups.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/keyvaults.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/managed_identities.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/role_mapping.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/configuration.tfvars
```

## Important Notes

1. **Certificate Management**: This example uses a self-signed certificate for demonstration. In production, use certificates from a trusted CA.

2. **Managed Identity**: The CDN Front Door service will use the managed identity to retrieve certificates from Key Vault.

3. **Permission Models**: 
   - **Access Policies**: Traditional approach, simpler setup, immediate permissions
   - **RBAC**: Modern approach, better security, may have permission propagation delays

4. **Custom Domains**: Update the `host_name` and certificate `subject_alternative_names` to match your actual domain.

5. **Backend Origins**: Update the `host_name` in origins to point to your actual backend services.

## Configuration Structure

### Dependencies Flow

```
Resource Groups
    ↓
Key Vault + Managed Identity
    ↓
Certificates + RBAC
    ↓
CDN Front Door Profile
```

### File Organization

- `resource_groups.tfvars`: Base infrastructure
- `keyvaults.tfvars`: Certificate storage with RBAC authorization
- `managed_identities.tfvars`: System and user-assigned identities
- `role_mapping.tfvars`: RBAC role assignments for Key Vault access
- `configuration.tfvars`: CDN Front Door main configuration

### RBAC vs Access Policies

This example uses **RBAC (Role-Based Access Control)** instead of traditional access policies for Key Vault access:

**RBAC Benefits:**
- ✅ More granular permissions with built-in Azure roles
- ✅ Better integration with Azure AD and Conditional Access
- ✅ Centralized permission management
- ✅ Audit trails and easier compliance
- ✅ Future-proof as Microsoft recommends RBAC over access policies

**Key RBAC Roles Used:**
- `Key Vault Certificates User`: Read access to certificates
- `Key Vault Secrets User`: Read access to secrets

### Troubleshooting Permission Issues

If you encounter `ForbiddenByRbac` errors when creating certificates:

1. **Ensure role propagation**: RBAC role assignments may take a few minutes to propagate. Wait 5-10 minutes and retry.

2. **Verify your user has Key Vault Administrator role**: Check that the role assignment worked:
   ```bash
   az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --scope /subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.KeyVault/vaults/<kv-name>
   ```

3. **Alternative: Use service principal**: For CI/CD scenarios, ensure your service principal has the appropriate roles assigned.

4. **Check deployment order**: Ensure `role_mapping.tfvars` is applied before certificate creation.

### Implementation Priority

This modular approach allows for:

- Better organization of complex configurations
- Easier maintenance and updates
- Clear separation of concerns
- Modern security patterns with RBAC
- Reusable components across different environments
