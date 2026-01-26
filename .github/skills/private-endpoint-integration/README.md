# Private Endpoint Integration Skill

Add Azure Private Endpoint support to Terraform modules for secure, private network connectivity.

## When to Use This Skill

Use this skill when you need to:
- Add private networking to a new or existing module
- Implement zero-trust network architecture
- Disable public access and use private connectivity
- Comply with security requirements for private-only access

## Quick Start

Ask Copilot:
- "Add private endpoint to the managed_redis module"
- "Enable private connectivity for storage_account"
- "Integrate Azure Private Link"
- "Add private endpoint support"

## What This Skill Covers

### Core Implementation
1. Identify service-specific subresource names
2. Create `private_endpoint.tf` file
3. Add required variables
4. Update root aggregator dependencies
5. Verify relative paths

### Example Creation
6. Create VNet, subnet, and DNS configuration
7. Create deployment example with private endpoint
8. Create mock test example
9. Configure network security

### Testing & Validation
10. Test private endpoint integration
11. Verify DNS resolution
12. Test connectivity from VNet

## Key Features

### Automatic Subresource Detection

The skill identifies correct subresource names for each Azure service:

| Service | Subresource |
|---------|-------------|
| Storage Account | `blob`, `file`, `queue`, `table`, `dfs` |
| Key Vault | `vault` |
| SQL Database | `sqlServer` |
| Redis Cache | `redisCache` |
| Container Registry | `registry` |
| Cognitive Services | `account` |

### Standard Integration Pattern

Uses shared `modules/networking/private_endpoint/` module:

```hcl
module "private_endpoint" {
  source            = "../../networking/private_endpoint"
  for_each          = var.private_endpoints
  resource_id       = azurerm_<resource>.id
  subnet_id         = <coalesce_pattern>
  subresource_names = try(each.value.subresource_names, ["<default>"])
  private_dns       = var.private_dns
  # ... standard parameters
}
```

### Complete Network Stack

Generates complete private networking example:
- ✅ Virtual Network
- ✅ Dedicated subnet with proper policies
- ✅ Private DNS zone with VNet links
- ✅ Network Security Group (optional)
- ✅ Service with public access disabled

### Service-Specific DNS Zones

Automatically uses correct Private Link DNS zone:

| Service | DNS Zone |
|---------|----------|
| Storage (blob) | `privatelink.blob.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| SQL Database | `privatelink.database.windows.net` |
| Redis Cache | `privatelink.redis.cache.windows.net` |
| Container Registry | `privatelink.azurecr.io` |
| Cognitive Services | `privatelink.cognitiveservices.azure.com` |

## Example Usage

### Scenario 1: Adding Private Endpoint to New Module

**User Request:**
```
I'm creating a managed_redis module. Add private endpoint support.
```

**Copilot Response (using this skill):**

1. Identifies subresource name: `redisCache`
2. Creates `modules/cache/managed_redis/private_endpoint.tf`
3. Adds required variables
4. Updates root aggregator
5. Creates complete example with VNet, subnet, DNS
6. Sets `public_network_access_enabled = false`
7. Provides test commands

### Scenario 2: Enabling Private Connectivity on Existing Module

**User Request:**
```
The storage_account module exists. Add private endpoint for blob access.
```

**Copilot Response:**

1. Checks if `private_endpoint.tf` exists
2. If not, creates it with `subresource_names = ["blob"]`
3. Adds variables if missing
4. Creates comprehensive example with:
   - VNet and subnet
   - Private DNS zone `privatelink.blob.core.windows.net`
   - DNS VNet link
   - Storage account with public access disabled
5. Tests integration

## Complete Example Generated

### Deployment Example

```hcl
# Virtual Network
vnets = {
  vnet1 = {
    name = "vnet-test-1"
    resource_group = { key = "rg_network" }
    address_space = ["10.0.0.0/16"]
  }
}

# Subnet for Private Endpoints
virtual_subnets = {
  pe_subnet = {
    name = "snet-private-endpoints"
    vnet = { key = "vnet1" }
    cidr = ["10.0.1.0/24"]
    
    # Required: Disable PE network policies
    private_endpoint_network_policies_enabled = false
  }
}

# Private DNS Zone
private_dns = {
  redis_dns = {
    name = "privatelink.redis.cache.windows.net"
    resource_group = { key = "rg_network" }
    
    vnet_links = {
      link1 = {
        name = "dns-link-vnet1"
        vnet = { key = "vnet1" }
      }
    }
  }
}

# Service with Private Endpoint
cache = {
  managed_redis = {
    redis1 = {
      name = "redis-instance-1"
      resource_group = { key = "rg_service" }
      
      # Disable public access
      public_network_access_enabled = false
      
      # Private Endpoint
      private_endpoints = {
        pe1 = {
          name = "pe-redis-instance-1"
          subnet = { key = "pe_subnet" }
          subresource_names = ["redisCache"]
          private_dns_zone = { key = "redis_dns" }
        }
      }
    }
  }
}
```

## Private Endpoint Best Practices Applied

### 1. Dedicated Subnet

```hcl
# Separate subnet for PEs with proper policies
private_endpoint_network_policies_enabled = false
```

### 2. Disable Public Access

```hcl
# Always disable when using PE
public_network_access_enabled = false
```

### 3. Private DNS Integration

```hcl
# Automatic DNS registration
private_dns_zone = { key = "dns1" }
```

### 4. Hub-Spoke Topology Support

```hcl
# Central PE in hub, DNS linked to spokes
vnet_links = {
  hub   = { vnet = { key = "hub_vnet" } }
  spoke1 = { vnet = { key = "spoke1_vnet" } }
  spoke2 = { vnet = { key = "spoke2_vnet" } }
}
```

## Integration Checklist Provided

- [ ] Service supports private endpoints (verified)
- [ ] Correct subresource names identified
- [ ] `private_endpoint.tf` created
- [ ] Required variables added
- [ ] Root aggregator updated
- [ ] Relative path verified
- [ ] VNet and subnet configured
- [ ] Private DNS zone created
- [ ] DNS VNet links configured
- [ ] Subnet policies disabled
- [ ] Public access disabled
- [ ] Tests passing

## Common Issues Handled

| Issue | Solution |
|-------|----------|
| Wrong subresource name | References Azure docs and existing modules |
| Module not found | Validates relative path |
| Subnet policy error | Sets `private_endpoint_network_policies_enabled = false` |
| DNS not resolving | Uses correct privatelink DNS zone name |
| PE not created | Ensures PE config in example |
| Public access still enabled | Explicitly disables in example |

## Advanced Scenarios

### Multiple Subresources (Storage Account)

```hcl
private_endpoints = {
  pe_blob = {
    subresource_names = ["blob"]
    private_dns_zone = { key = "dns_blob" }
  }
  pe_file = {
    subresource_names = ["file"]
    private_dns_zone = { key = "dns_file" }
  }
}
```

### Cross-Landing-Zone Private Endpoints

```hcl
private_endpoints = {
  pe1 = {
    subnet = {
      lz_key = "connectivity"  # Remote LZ
      key    = "pe_subnet"
    }
    private_dns_zone = {
      lz_key = "connectivity"
      key    = "dns1"
    }
  }
}
```

### Custom NSG for PE Subnet

```hcl
network_security_groups = {
  nsg_pe = {
    name = "nsg-private-endpoints"
    nsg_inbound_rules = [
      {
        name                       = "AllowVnetInbound"
        priority                   = 100
        access                     = "Allow"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  }
}

virtual_subnets = {
  pe_subnet = {
    network_security_group = { key = "nsg_pe" }
  }
}
```

## Testing Strategy

### Mock Test
```bash
cd examples
terraform test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/200-<service>-private-endpoint/configuration.tfvars \
  -verbose
```

**Alternative**: `terraform -chdir=examples test ...`

### Real Deployment
```bash
terraform_with_var_files \
  --dir /<category>/<service>/200-<service>-private-endpoint/ \
  --action plan
```

### Verify Connectivity
```bash
# DNS resolution (should return private IP)
nslookup <service-name>.<service>.azure.net

# Test from VM in same VNet
curl -v https://<service-name>.<service>.azure.net
```

## Files Modified/Created

- `modules/<category>/<module>/private_endpoint.tf` - New file
- `modules/<category>/<module>/variables.tf` - Add PE variables
- `/<category>_<module_names>.tf` - Update dependencies
- `examples/<category>/<service>/200-*/configuration.tfvars` - Deployment example

## Quick Reference

### Required Variables

```hcl
variable "private_endpoints" { default = {} }
variable "private_dns" { default = {} }
variable "resource_groups" { default = {} }
variable "remote_objects" {
  type = object({
    virtual_subnets = optional(map(any), {})
  })
  default = {}
}
```

### Standard Template

```hcl
module "private_endpoint" {
  source            = "../../networking/private_endpoint"
  for_each          = var.private_endpoints
  resource_id       = <resource>.id
  subnet_id         = <coalesce_pattern>
  subresource_names = try(each.value.subresource_names, ["<default>"])
  private_dns       = var.private_dns
}
```

### Example Configuration

```hcl
private_endpoints = {
  pe1 = {
    subnet            = { key = "pe_subnet" }
    subresource_names = ["<subresource>"]
    private_dns_zone  = { key = "dns1" }
  }
}
```

## Prerequisites

Before using this skill:
- ✅ Module exists and is functional
- ✅ Service supports private endpoints (verify in Azure docs)
- ✅ Know the correct subresource names

## Success Criteria

Private endpoint integration is complete when:
- ✅ Mock tests pass
- ✅ PE module called correctly
- ✅ Examples include VNet, subnet, DNS
- ✅ Public access disabled
- ✅ DNS resolves to private IP
- ✅ Connectivity works from VNet

## Related Skills

- **module-creation** - Include PEs during module creation
- **mock-testing** - Test PE integration
- **diagnostics-integration** - Often combined with PE

## Tips

- **Use existing modules** as reference (`find modules -name "private_endpoint.tf"`)
- **Verify subresource names** in Azure documentation
- **Always disable public access** when using private endpoints
- **Test DNS resolution** after deployment
- **Use dedicated subnet** for private endpoints
- **Don't forget** to disable subnet policies

## Need Help?

If Copilot doesn't automatically use this skill:
- Explicitly mention "private endpoint" or "private link"
- Ask to "add private connectivity"
- Reference "secure network access" or "zero-trust"
