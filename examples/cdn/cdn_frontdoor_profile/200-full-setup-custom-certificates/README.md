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

#### Problem: `ForbiddenByRbac` errors during operations

If you encounter `ForbiddenByRbac` errors when creating, reading, or destroying certificates:

1. **Wait for RBAC propagation**: RBAC role assignments may take 5-10 minutes to propagate. Wait and retry.

2. **Verify role assignments**: Check that your role assignments are active:
   ```bash
   az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --scope /subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.KeyVault/vaults/<kv-name>
   ```

3. **For `terraform destroy` issues**: If destroy fails with permission errors, you have several options:

   a) **Wait and retry**: Simply wait 5-10 minutes and run destroy again
   
   b) **Force deletion**: Use Azure CLI to delete the certificate first:
   ```bash
   az keyvault certificate delete --name cdn-certificate --vault-name <keyvault-name>
   az keyvault certificate purge --name cdn-certificate --vault-name <keyvault-name>
   ```
   
   c) **Targeted destroy**: Target specific resources in order:
   ```bash
   # First destroy CDN resources
   terraform destroy -target=module.example.module.cdn_frontdoor_profile -auto-approve
   
   # Then destroy certificates
   terraform destroy -target=module.example.module.keyvault_certificate_requests -auto-approve
   
   # Finally destroy remaining infrastructure
   terraform destroy -auto-approve
   ```

#### Problem: Two-Phase Deployment Required

When using RBAC with Key Vault, you may need a two-phase deployment:

```bash
# Phase 1: Deploy infrastructure and roles (excluding certificates)
terraform apply \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/resource_groups.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/managed_identities.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/role_mapping.tfvars \
  -target=module.example.module.resource_groups \
  -target=module.example.module.keyvaults \
  -target=module.example.module.managed_identities \
  -target=module.example.azurerm_role_assignment

# Wait 5-10 minutes for RBAC propagation, then Phase 2: Deploy certificates and CDN
terraform apply \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/resource_groups.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/keyvaults.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/managed_identities.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/role_mapping.tfvars \
  -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/configuration.tfvars
```

#### Why RBAC Can Have Timing Issues

When using RBAC with Key Vault, there's an inherent timing dependency:
- ✅ Certificate creation requires RBAC permissions
- ⏱️ RBAC role assignments need time to propagate (5-10 minutes)
- 🔄 Terraform operations may execute before propagation completes
- 🛠️ The framework uses `depends_on = [azurerm_role_assignment.for]` to help with ordering

**Benefits of RBAC approach:**
- ✅ Modern, Microsoft-recommended approach
- ✅ Better security and audit capabilities
- ✅ Integration with Azure AD and Conditional Access
- ✅ Granular permission control

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
