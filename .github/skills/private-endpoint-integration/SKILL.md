---
name: private-endpoint-integration
description: Add Azure Private Endpoint integration to Terraform modules for secure, private network connectivity. Use this skill when adding private networking capabilities to modules that support Azure Private Link.
---

# Private Endpoint Integration for Azure CAF Modules

Add Azure Private Endpoint support to modules for secure, private network access to Azure services.

## When to Use This Skill

Use this skill when:
- Creating a new module for a resource that supports Private Link
- Adding private networking to an existing module
- User asks to "add private endpoint" or "enable private connectivity"
- Implementing zero-trust or hub-spoke network architectures
- Compliance requires private network access only

## Azure Services That Support Private Endpoints

Most Azure PaaS services support Private Link. Common examples:
- ✅ Storage Accounts (Blob, File, Queue, Table, Dfs)
- ✅ Key Vaults
- ✅ SQL Databases
- ✅ Cosmos DB
- ✅ Azure Cache for Redis
- ✅ App Services
- ✅ Container Registry
- ✅ Cognitive Services
- ✅ Azure AI Services
- ✅ Event Hubs
- ✅ Service Bus

## Verification: Does the Service Support Private Endpoints?

**Check Azure Provider Documentation**:
```
Resource: azurerm_<resource_name>
Look for: Properties related to private_endpoint_connection or network rules
```

**Or check Azure documentation** for "[service name] private link" or "[service name] private endpoint".

**Key Indicator**: Service has `subresource_names` (e.g., "blob", "vault", "sqlServer").

---

## Step-by-Step Implementation

### Step 1: Check if Module Already Supports Private Endpoints

```bash
# Check if private_endpoint.tf exists
ls modules/<category>/<module_name>/private_endpoint.tf

# Check if variables exist
grep "private_endpoints" modules/<category>/<module_name>/variables.tf
```

If the file exists, the module already supports private endpoints. Skip to Step 6 (Creating Examples).

---

### Step 2: Identify Subresource Names

Each Azure service has specific subresource names for private endpoints.

**Common Subresource Names**:

| Service | Subresource Names |
|---------|-------------------|
| Storage Account | `blob`, `file`, `queue`, `table`, `dfs` |
| Key Vault | `vault` |
| SQL Database | `sqlServer` |
| Cosmos DB | `sql`, `mongodb`, `cassandra`, `table`, `gremlin` |
| Redis Cache | `redisCache` |
| Container Registry | `registry` |
| App Service | `sites` |
| Cognitive Services | `account` |
| Event Hub | `namespace` |
| Service Bus | `namespace` |
| Azure AI Services | `account` |

**How to Find**:
1. Check Azure documentation for the service
2. Look at existing modules: `grep "subresource_names" modules/*/*/private_endpoint.tf`
3. Azure CLI: `az network private-link-resource list --name <resource> --resource-group <rg> --type <type>`

---

### Step 3: Create private_endpoint.tf File

**Location**: `modules/<category>/<module_name>/private_endpoint.tf`

**Standard Template**:

```hcl
#
# Private endpoint configuration
#

module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.private_endpoints

  resource_id      = <resource_reference>.id
  name             = each.value.name
  location         = try(each.value.location, local.location)
  resource_group   = try(each.value.resource_group, var.resource_groups[try(each.value.resource_group.key, each.value.resource_group_key)])
  subnet_id        = can(each.value.subnet_id) ? each.value.subnet_id : var.remote_objects.virtual_subnets[try(each.value.subnet.lz_key, var.client_config.landingzone_key)][each.value.subnet.key].id
  settings         = each.value
  global_settings  = var.global_settings
  base_tags        = local.tags
  private_dns      = var.private_dns
  client_config    = var.client_config

  # Service-specific subresource names
  subresource_names = try(each.value.subresource_names, ["<default_subresource>"])
}
```

**Key Elements**:
- **Source**: Always `../../networking/private_endpoint` (relative path)
- **for_each**: Iterate over private_endpoints configuration
- **resource_id**: Reference to main resource's ID
- **subnet_id**: Coalesce pattern for direct ID or key-based reference
- **subresource_names**: Service-specific (required)

**Examples by Resource Type**:

```hcl
# Storage Account
resource_id       = azurerm_storage_account.storage.id
subresource_names = try(each.value.subresource_names, ["blob"])

# Key Vault
resource_id       = azurerm_key_vault.keyvault.id
subresource_names = try(each.value.subresource_names, ["vault"])

# Managed Redis
resource_id       = azurerm_redis_cache.redis.id
subresource_names = try(each.value.subresource_names, ["redisCache"])

# SQL Database (use server ID, not database ID)
resource_id       = azurerm_mssql_server.server.id
subresource_names = try(each.value.subresource_names, ["sqlServer"])

# Cognitive Services
resource_id       = azurerm_cognitive_account.cognitive.id
subresource_names = try(each.value.subresource_names, ["account"])

# Container Registry
resource_id       = azurerm_container_registry.acr.id
subresource_names = try(each.value.subresource_names, ["registry"])
```

---

### Step 4: Add Private Endpoint Variables

**Location**: `modules/<category>/<module_name>/variables.tf`

**Add these variables**:

```hcl
variable "private_endpoints" {
  description = "Private endpoint configuration for the resource"
  default     = {}
}

variable "private_dns" {
  description = "Private DNS zones for private endpoint DNS registration"
  default     = {}
}

variable "resource_groups" {
  description = "Resource groups for cross-resource references"
  default     = {}
}

variable "remote_objects" {
  description = "Remote objects for dependency resolution"
  type = object({
    virtual_subnets = optional(map(any), {})
  })
  default = {}
}
```

**Notes**:
- `private_endpoints`: Main configuration (default = {})
- `private_dns`: Required for DNS zone integration
- `resource_groups`: For resource group resolution
- `remote_objects`: For subnet resolution by key

---

### Step 5: Update Root Aggregator

**Location**: `/<category>_<module_names>.tf`

**Ensure these are passed to module**:

```hcl
module "<module_name>" {
  source   = "./modules/<category>/<module_name>"
  for_each = local.<category>.<module_name>

  # ... existing parameters ...

  # Add these if not present
  resource_groups = local.combined_objects_resource_groups
  private_dns     = local.combined_objects_private_dns
  
  remote_objects = {
    virtual_subnets = local.combined_objects_virtual_subnets
    # ... other remote objects ...
  }
}
```

---

### Step 6: Verify Relative Path

The private endpoint module path must be correct based on module depth.

**Standard Module Structure** (depth 2):
```
modules/
└── <category>/
    └── <module_name>/
        └── private_endpoint.tf → source = "../../networking/private_endpoint"
```

**Module with Submodule** (depth 3):
```
modules/
└── <category>/
    └── <module_name>/
        └── <submodule>/
            └── private_endpoint.tf → source = "../../../networking/private_endpoint"
```

**Verification Command**:
```bash
# From module directory
cd modules/<category>/<module_name>/
realpath ../../networking/private_endpoint
# Should output: /path/to/repo/modules/networking/private_endpoint
```

---

### Step 7: Create Example with Private Endpoint

**Location**: `examples/<category>/<service>/200-<service>-private-endpoint/configuration.tfvars`

**Standard Example Template**:

```hcl
global_settings = {
  default_region = "region1"
  regions = {
    region1 = "westeurope"
  }
  random_length = 5
}

resource_groups = {
  rg_service = {
    name = "service-test-1"
  }
  rg_network = {
    name = "network-test-1"
  }
}

# Virtual Network for Private Endpoint
vnets = {
  vnet1 = {
    name = "vnet-test-1"
    resource_group = {
      key = "rg_network"
    }
    address_space = ["10.0.0.0/16"]
  }
}

# Subnet for Private Endpoint
virtual_subnets = {
  subnet1 = {
    name = "snet-private-endpoints"
    vnet = {
      key = "vnet1"
    }
    cidr = ["10.0.1.0/24"]
    
    # Disable private endpoint network policies
    private_endpoint_network_policies_enabled = false
  }
}

# Private DNS Zone
private_dns = {
  dns1 = {
    name = "privatelink.<service>.azure.net"  # Service-specific
    resource_group = {
      key = "rg_network"
    }
    
    # Link to VNet
    vnet_links = {
      link1 = {
        name = "dns-link-vnet1"
        vnet = {
          key = "vnet1"
        }
      }
    }
  }
}

# Main service with Private Endpoint
<category> = {
  <service_name> = {
    service1 = {
      name = "service-instance-1"
      resource_group = {
        key = "rg_service"
      }
      
      # Disable public network access
      public_network_access_enabled = false
      
      # Service-specific configuration
      # ... (service settings)
      
      # Private Endpoint configuration
      private_endpoints = {
        pe1 = {
          name = "pe-service-instance-1"
          
          # Subnet for private endpoint
          subnet = {
            key = "subnet1"
          }
          
          # Optional: Specify resource group
          resource_group = {
            key = "rg_network"
          }
          
          # Service-specific subresource (optional if default is correct)
          subresource_names = ["<subresource>"]  # e.g., "blob", "vault", "redisCache"
          
          # Private DNS integration
          private_dns_zone = {
            key = "dns1"
          }
        }
      }
    }
  }
}
```

**Service-Specific DNS Zones**:

| Service | Private DNS Zone Name |
|---------|----------------------|
| Storage Account (blob) | `privatelink.blob.core.windows.net` |
| Storage Account (file) | `privatelink.file.core.windows.net` |
| Key Vault | `privatelink.vaultcore.azure.net` |
| SQL Database | `privatelink.database.windows.net` |
| Redis Cache | `privatelink.redis.cache.windows.net` |
| Container Registry | `privatelink.azurecr.io` |
| Cognitive Services | `privatelink.cognitiveservices.azure.com` |
| Azure AI Services | `privatelink.openai.azure.com` |
| Cosmos DB (SQL) | `privatelink.documents.azure.com` |
| App Service | `privatelink.azurewebsites.net` |

---

### Step 8: Test Private Endpoint with Mock Tests

**Note**: Mock tests use the same configuration file as deployment examples. No separate mock files needed.

---

### Step 9: Network Security Group Considerations

Private endpoints require proper NSG configuration.

**In virtual_subnets configuration**:

```hcl
virtual_subnets = {
  subnet1 = {
    name = "snet-private-endpoints"
    vnet = { key = "vnet1" }
    cidr = ["10.0.1.0/24"]
    
    # Disable PE network policies (required)
    private_endpoint_network_policies_enabled = false
    
    # Optional: NSG for additional security
    network_security_group = {
      key = "nsg_pe"
    }
  }
}

# NSG configuration (optional but recommended)
network_security_groups = {
  nsg_pe = {
    name = "nsg-private-endpoints"
    resource_group = { key = "rg_network" }
    
    # Allow necessary traffic
    nsg_inbound_rules = [
      {
        name                       = "AllowVnetInbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
      }
    ]
  }
}
```

---

### Step 10: Test Private Endpoint Integration

**Mock Test**:
```bash
cd examples
terraform test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/200-<service>-private-endpoint/configuration.tfvars \
  -verbose
```

**Alternative (single command)**:
```bash
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file=./<category>/<service>/200-<service>-private-endpoint/configuration.tfvars \
  -verbose
```

**Real Deployment Test** (optional):
```bash
# Verify Azure subscription
az account show --query "{subscriptionId:id, name:name}" -o table
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

cd examples
terraform_with_var_files \
  --dir /<category>/<service>/200-<service>-private-endpoint/ \
  --action plan \
  --auto auto \
  --workspace test
```

---

### Step 11: Verify Private Endpoint Connectivity

After deployment, verify the private endpoint works:

```bash
# Get private endpoint IP
az network private-endpoint show \
  --name <pe-name> \
  --resource-group <rg-name> \
  --query 'customDnsConfigs[0].ipAddresses[0]' -o tsv

# Test DNS resolution (should return private IP)
nslookup <service-name>.<service>.azure.net

# Test connectivity from VM in same VNet
curl -v https://<service-name>.<service>.azure.net
```

---

## Private Endpoint Module Structure

The shared private endpoint module (`modules/networking/private_endpoint/`) handles:
- Creates `azurerm_private_endpoint` resource
- Resolves subnet by key or direct ID
- Configures subresource names
- Integrates with private DNS zones
- Manages resource group placement
- Applies tags consistently

**You don't modify** the private endpoint module - just use it.

---

## Integration Checklist

- [ ] Service supports private endpoints (verified in Azure docs)
- [ ] Identified correct subresource names for service
- [ ] Created `private_endpoint.tf` in module directory
- [ ] Added required variables (`private_endpoints`, `private_dns`, etc.)
- [ ] Verified relative path (`../../networking/private_endpoint`)
- [ ] Updated root aggregator to pass dependencies
- [ ] Created deployment example with VNet, subnet, and DNS
- [ ] Created mock test example
- [ ] Tested mock test passes
- [ ] Verified DNS zone name is correct for service
- [ ] Disabled public network access in example
- [ ] Set `private_endpoint_network_policies_enabled = false` on subnet

---

## Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Module not found" | Wrong relative path | Verify with `realpath ../../networking/private_endpoint` |
| "Unknown variable: private_endpoints" | Variable not added | Add all required variables to `variables.tf` |
| "Invalid subresource name" | Wrong subresource for service | Check Azure docs or existing modules |
| "Subnet policy error" | PE policies not disabled | Set `private_endpoint_network_policies_enabled = false` |
| "DNS not resolving" | Wrong DNS zone name | Use correct privatelink DNS for service |
| "PE not created" | Empty private_endpoints object | Ensure PE config in example |
| "Cannot create PE" | Public access still enabled | Set `public_network_access_enabled = false` |

---

## Private Endpoint Best Practices

### 1. Always Use Private DNS

```hcl
# Include private DNS zone
private_dns = {
  dns1 = {
    name = "privatelink.<service>.azure.net"
    vnet_links = {
      link1 = { vnet = { key = "vnet1" } }
    }
  }
}
```

### 2. Disable Public Access

```hcl
# In service configuration
public_network_access_enabled = false
```

### 3. Dedicated Subnet

```hcl
# Create separate subnet for private endpoints
virtual_subnets = {
  pe_subnet = {
    name = "snet-private-endpoints"
    # Dedicated CIDR range
    cidr = ["10.0.10.0/24"]
    private_endpoint_network_policies_enabled = false
  }
}
```

### 4. Hub-Spoke Topology

```hcl
# In hub VNet - create PE and DNS
# In spoke VNets - link DNS zones
private_dns = {
  dns1 = {
    vnet_links = {
      hub_link   = { vnet = { key = "hub_vnet" } }
      spoke1_link = { vnet = { key = "spoke1_vnet" } }
      spoke2_link = { vnet = { key = "spoke2_vnet" } }
    }
  }
}
```

### 5. NSG Rules for Private Endpoints

```hcl
# Allow only necessary VNet traffic
nsg_inbound_rules = [
  {
    name                       = "AllowVnetInbound"
    access                     = "Allow"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
]
```

---

## Storage Account Multiple Subresources

Storage accounts can have multiple private endpoints for different subresources:

```hcl
storage_accounts = {
  storage1 = {
    private_endpoints = {
      # Blob private endpoint
      pe_blob = {
        name              = "pe-storage-blob"
        subnet            = { key = "pe_subnet" }
        subresource_names = ["blob"]
        private_dns_zone  = { key = "dns_blob" }
      }
      
      # File private endpoint
      pe_file = {
        name              = "pe-storage-file"
        subnet            = { key = "pe_subnet" }
        subresource_names = ["file"]
        private_dns_zone  = { key = "dns_file" }
      }
    }
  }
}

# Multiple DNS zones
private_dns = {
  dns_blob = {
    name = "privatelink.blob.core.windows.net"
  }
  dns_file = {
    name = "privatelink.file.core.windows.net"
  }
}
```

---

## Cross-Landing-Zone Private Endpoints

For cross-LZ scenarios:

```hcl
private_endpoints = {
  pe1 = {
    # Remote subnet reference
    subnet = {
      lz_key = "connectivity"  # Different landing zone
      key    = "pe_subnet"
    }
    
    # Remote DNS reference
    private_dns_zone = {
      lz_key = "connectivity"
      key    = "dns1"
    }
  }
}
```

---

## Example Services with Private Endpoints

Reference existing implementations:

```bash
# Find modules with private endpoints already implemented
find modules -name "private_endpoint.tf" -type f

# Example outputs:
# modules/storage/storage_account/private_endpoint.tf
# modules/keyvault/keyvault/private_endpoint.tf
# modules/databases/mssql_server/private_endpoint.tf
# modules/cache/managed_redis/private_endpoint.tf
```

**Study existing patterns**:
```bash
cat modules/storage/storage_account/private_endpoint.tf
cat examples/storage/storage_account/200-storage-account-private-endpoint/configuration.tfvars
```

---

## Quick Reference: Standard Private Endpoint Block

**In private_endpoint.tf**:
```hcl
module "private_endpoint" {
  source            = "../../networking/private_endpoint"
  for_each          = var.private_endpoints
  resource_id       = <resource>.id
  name              = each.value.name
  location          = local.location
  subnet_id         = coalesce(try(each.value.subnet_id, null), var.remote_objects.virtual_subnets[...].id)
  subresource_names = try(each.value.subresource_names, ["<default>"])
  private_dns       = var.private_dns
  # ... standard parameters
}
```

**In variables.tf**:
```hcl
variable "private_endpoints" {
  default = {}
}
variable "private_dns" {
  default = {}
}
```

**In example**:
```hcl
private_endpoints = {
  pe1 = {
    subnet = { key = "pe_subnet" }
    subresource_names = ["<service_subresource>"]
    private_dns_zone = { key = "dns1" }
  }
}
```

---

## Related Skills

- **module-creation** - Include private endpoints during module creation
- **mock-testing** - Test private endpoint integration
- **diagnostics-integration** - Often combined with PE for secure monitoring

---

## Summary

Adding private endpoints to a module:
1. ✅ Identify subresource names for the service
2. ✅ Create `private_endpoint.tf` with module call
3. ✅ Add required variables
4. ✅ Update root aggregator dependencies
5. ✅ Create examples with VNet, subnet, DNS
6. ✅ Disable public access
7. ✅ Test with mock tests
8. ✅ Verify DNS and connectivity

This enables secure, private network access to Azure services following zero-trust principles.
