# Instructions for Creating a Terraform Module

## Language Requirements

**All generated content for this repository must be in English.** This includes:
- Code comments
- Documentation
- Variable descriptions
- Resource names and descriptions
- Error messages
- README files
- Commit messages
- Any other text content

This ensures consistency and accessibility for the international development team and community.

## For new modules

### Directory Structure

/ is the root directory of the repository. Create the following directory structure for the Terraform module:

/modules
└── /category_name
└──/module_name
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── diagnostics.tf
├── locals.tf
├── module_name.tf
|── resource1.tf
|── resource2.tf
├── resource1
│ ├── resource1.tf
│ ├── main.tf
│ ├── output.tf
│ ├── providers.tf
│ └── variables.tf
├── resource2
│ ├── resource2.tf
│ ├── main.tf
│ ├── output.tf
│ ├── providers.tf
│ └── variables.tf
/category_name_module_names.tf

module_name is the name of the resource without the provider prefix. For example, if the resource is azurerm_container_app, the module_name would be container_app.

module_names is the name of the resource without the provider prefix and with the plural form. For example, if the resource is azurerm_container_app, the module_names would be container_apps.

resource1 and resource2 are examples of resources that can be added to the module. Add as many resources as needed. If there are no resources, don't create the resource directories.

Usually, resource1 and resource2 are components of the module. For example, if the module is a module_name, resource1 could be module_name_resource1 and resource2 could be module_name_resource2,

use resource1 and resource2 as the names of the directories, don't repeat the module_name in the directory name.

If category_name is not provided, the module_name directory should be created directly under the /modules directory.

If category_name is not provided, /category_name_module_names.tf should be created like /module_names.tf.

For example for a module with category_name equal to cognitive_services and module_name equal to azurerm_cognitive_account, and with one resource named azurerm_cognitive_account_customer_managed_key:

```plaintext
/modules
└── /cognitive_services
                └──/cognitive_account
                    ├── main.tf
                    ├── outputs.tf
                    ├── providers.tf
                    ├── variables.tf
                    ├── diagnostics.tf
                    ├── locals.tf
                    ├── cognitive_account.tf
                    |── customer_managed_key.tf
                    ├── customer_managed_key
                    │   ├── customer_managed_key.tf
                    │   ├── main.tf
                    │   ├── output.tf
                    │   ├── providers.tf
                    │   └── variables.tf
/cognitive_services_cognitive_account.tf
```

### No Resources

If the module does not require any resources, do not create any resource directories or files. Ensure that the module only includes the necessary configuration files such as `main.tf`, `outputs.tf`, `providers.tf`, `variables.tf`, `diagnostics.tf`, `locals.tf`, and `module_name.tf`.

For example, if the module is `azurerm_ai_services` under the category `cognitive_services`, the directory structure should look like this:

```plaintext
/modules
└── /cognitive_services
    └── /ai_services
        ├── main.tf
        ├── outputs.tf
        ├── providers.tf
        ├── variables.tf
        ├── diagnostics.tf
        ├── locals.tf
        ├── ai_services.tf
/cognitive_services_ai_services.tf
```

## Azure CAF Naming Convention Implementation

Implement Azure Cloud Adoption Framework (CAF) naming conventions using the `aztfmod/azurecaf` provider for ALL modules to ensure consistent, compliant, and standardized resource names across the entire CAF framework.

### Core Requirements

1. **Every module with named Azure resources MUST implement azurecaf naming**
2. **Create `azurecaf_name.tf` file in every module and submodule directory**
3. **All Azure resource names MUST use azurecaf generated names**
4. **Support global naming settings (prefixes, suffixes, use_slug, separator)**

### Provider Configuration

Include azurecaf provider in ALL `providers.tf` files for modules with named resources:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.1.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}
```

### Universal azurecaf_name.tf Pattern

Create `azurecaf_name.tf` file in EVERY module and submodule that creates named Azure resources:

#### For Main Modules

```hcl
resource "azurecaf_name" "main_resource" {
  name          = var.settings.name
  resource_type = "azurerm_[resource_type]"  # e.g., azurerm_storage_account
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
```

#### For Submodules

```hcl
resource "azurecaf_name" "subresource" {
  name          = var.settings.name
  resource_type = "azurerm_[subresource_type]"  # e.g., azurerm_storage_container
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
```

### Resource Type Mapping

Map each Azure resource to its corresponding azurecaf resource type. Common mappings:

| Azure Resource | azurecaf Resource Type |
|---------------|----------------------|
| azurerm_resource_group | `azurerm_resource_group` |
| azurerm_storage_account | `azurerm_storage_account` |
| azurerm_storage_container | `azurerm_storage_container` |
| azurerm_key_vault | `azurerm_key_vault` |
| azurerm_virtual_network | `azurerm_virtual_network` |
| azurerm_subnet | `azurerm_subnet` |
| azurerm_network_security_group | `azurerm_network_security_group` |
| azurerm_public_ip | `azurerm_public_ip` |
| azurerm_application_gateway | `azurerm_application_gateway` |
| azurerm_kubernetes_cluster | `azurerm_kubernetes_cluster` |
| azurerm_container_registry | `azurerm_container_registry` |
| azurerm_app_service_plan | `azurerm_app_service_plan` |
| azurerm_linux_web_app | `azurerm_linux_web_app` |
| azurerm_windows_web_app | `azurerm_windows_web_app` |
| azurerm_function_app | `azurerm_function_app` |
| azurerm_mssql_server | `azurerm_mssql_server` |
| azurerm_mssql_database | `azurerm_mssql_database` |
| azurerm_cosmosdb_account | `azurerm_cosmosdb_account` |
| azurerm_cdn_profile | `azurerm_cdn_profile` |
| azurerm_cdn_frontdoor_profile | `azurerm_cdn_frontdoor_profile` |
| azurerm_cdn_frontdoor_endpoint | `azurerm_cdn_frontdoor_endpoint` |

### Universal Resource Implementation

Update ALL resource definitions to use azurecaf generated names:

```hcl
# ❌ INCORRECT - Direct name usage
resource "azurerm_[resource_type]" "resource_name" {
  name = var.settings.name
  # ... other attributes
}

# ✅ CORRECT - azurecaf generated name
resource "azurerm_[resource_type]" "resource_name" {
  name = azurecaf_name.main_resource.result
  # ... other attributes
}
```

### Universal Outputs Pattern

Add `name` output to ALL modules with named resources:

```hcl
# ALWAYS include the CAF-compliant name output
output "name" {
  value       = azurecaf_name.main_resource.result
  description = "The CAF-compliant name of the [resource_type]"
}

# Standard resource outputs
output "id" {
  value = azurerm_[resource_type].resource_name.id
}

# ... other specific outputs for the resource type
```

### Implementation Steps for Any Module

1. **Add azurecaf provider** to `providers.tf`
2. **Create `azurecaf_name.tf`** file with appropriate resource type
3. **Update resource definition** to use `azurecaf_name.resource.result`
4. **Add name output** to expose CAF-compliant name
5. **Test with examples** that include azurecaf provider

### Common Implementation Patterns

#### Single Resource Module
```hcl
# azurecaf_name.tf
resource "azurecaf_name" "storage_account" {
  name          = var.settings.name
  resource_type = "azurerm_storage_account"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}

# storage_account.tf
resource "azurerm_storage_account" "storage_account" {
  name                = azurecaf_name.storage_account.result
  resource_group_name = local.resource_group_name
  location            = local.location
  # ... other configuration
}
```

#### Multi-Resource Module with Submodules
```hcl
# Main module azurecaf_name.tf
resource "azurecaf_name" "main_resource" {
  name          = var.settings.name
  resource_type = "azurerm_main_resource_type"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}

# Submodule azurecaf_name.tf
resource "azurecaf_name" "subresource" {
  name          = var.settings.name
  resource_type = "azurerm_subresource_type"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = true
  separator     = "-"
}
```

### Global Settings Integration

Ensure EVERY module properly integrates with global naming settings:

```hcl
# variables.tf - Standard global_settings variable (ALWAYS include this)
variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  
  These are the key naming settings:
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name. Defaults to true.
  DESCRIPTION
  type = any
}
```

### Examples Integration

Update ALL examples to include azurecaf provider:

```hcl
# examples/main.tf - ALWAYS include azurecaf provider
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}
```

### Benefits for ALL Modules

1. **Consistency**: Standardized naming across ALL Azure resources in CAF
2. **Compliance**: Automatic adherence to Azure naming conventions
3. **Validation**: Built-in validation of name length and character restrictions
4. **Flexibility**: Configurable prefixes, suffixes, and separators per environment
5. **Cleanliness**: Automatic removal of invalid characters
6. **Identification**: Clear resource type identification through naming slugs
7. **Scalability**: Works across all Azure resource types and landing zones

### Implementation Priority

1. **New Modules**: MUST implement azurecaf naming from creation
2. **Existing Critical Modules**: Update high-usage modules first
3. **Legacy Modules**: Gradual migration with backward compatibility
4. **Examples**: Update to support azurecaf in all example configurations

### Reference Implementations

- `modules/cdn/cdn_frontdoor_profile/` - Complete example with azurecaf naming
- `modules/networking/network_manager/` - Multi-resource module pattern
- `examples/` - Updated with azurecaf provider support

## Submodule Dependency Pattern

When creating modules with multiple submodules (subresources), follow the established pattern used by modules like `network_manager` and `cdn_frontdoor_profile`. This pattern ensures proper dependency management and consistency across the CAF framework.

### Key Principles

1. **All dependencies between submodules must be passed through `var.remote_objects`**
2. **Never pass resource IDs directly as separate variables between modules**
3. **Use `coalesce()` with `try()` pattern to resolve resource dependencies**
4. **Use pluralized names for module calls (e.g., `endpoints`, `origins`, not `endpoint`, `origin`)**

### Pattern Implementation

#### Parent Module Submodule Calls

In the parent module, call submodules using this pattern:

```hcl
# Example: calling endpoints submodule
module "endpoints" {
  source   = "./endpoint"
  for_each = try(var.settings.endpoints, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
  })
}

# Example: calling origins submodule that depends on origin_groups
module "origins" {
  source   = "./origin"
  for_each = try(var.settings.origins, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_origin_groups = module.origin_groups
  })

  depends_on = [module.origin_groups]
}
```

#### Submodule Variables

Submodule `variables.tf` files should only contain the standard variables:

```hcl
variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = "Configuration settings for the resource."
  type        = any
}

variable "resource_group" {
  description = "Resource group object."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for dependencies."
  type        = any
}
```

**❌ DO NOT include direct ID variables like:**

- `variable "cdn_frontdoor_profile_id"`
- `variable "origin_groups"`
- `variable "rule_sets"`

#### Submodule Resource Implementation

In submodule resources, use the `coalesce()` pattern to resolve dependencies:

```hcl
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name = azurecaf_name.endpoint.result
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )
  enabled = try(var.settings.enabled, true)

  # ... other configuration
}

# Example with dependency on other submodule
resource "azurerm_cdn_frontdoor_origin" "origin" {
  name = azurecaf_name.origin.result
  cdn_frontdoor_origin_group_id = coalesce(
    try(var.settings.cdn_frontdoor_origin_group_id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)][var.settings.origin_group.key].id, null)
  )

  # ... other configuration
}
```

#### Parent Module Outputs

Use pluralized names in outputs:

```hcl
output "endpoints" {
  value = module.endpoints
}

output "origin_groups" {
  value = module.origin_groups
}

output "origins" {
  value = module.origins
}
```

### Benefits of This Pattern

1. **Consistency**: All modules follow the same dependency resolution pattern
2. **Flexibility**: Resources can be referenced by direct ID or by key lookup
3. **Maintainability**: Clear separation of concerns between modules
4. **Scalability**: Supports complex dependency chains between submodules
5. **CAF Compliance**: Aligns with the established Cloud Adoption Framework standards

### Example Reference Modules

- `modules/networking/network_manager` - Reference implementation
- `modules/cdn/cdn_frontdoor_profile` - Recently refactored to follow this pattern

## Key Vault Certificates and Managed Identity Pattern

When working with modules that require SSL/TLS certificates from Key Vault, follow these established patterns for security, maintainability, and CAF compliance.

### Key Principles

1. **Always use certificate keys instead of direct Key Vault certificate IDs**
2. **Use managed identities for secure access to Key Vault**
3. **Separate configuration concerns into multiple `.tfvars` files**
4. **Follow the `coalesce(try(...))` pattern for certificate resolution**

### Certificate Reference Pattern

#### ❌ DO NOT use direct certificate IDs:

```hcl
# Wrong approach - direct ID
secrets = {
  secret1 = {
    name = "my-secret"
    secret = {
      customer_certificate = {
        key_vault_certificate_id = "/subscriptions/.../certificates/cert1"
      }
    }
  }
}
```

#### ✅ DO use certificate keys with proper resolution:

```hcl
# Correct approach - key reference
secrets = {
  secret1 = {
    name = "my-secret"
    secret = {
      customer_certificate = {
        certificate_request = {
          key = "my_certificate_key"
          # lz_key = "remote_lz"  # Optional for remote landing zone
        }
      }
    }
  }
}
```

### Key Vault Certificate Request Structure

Use this structure for `keyvault_certificate_requests`:

```hcl
keyvault_certificate_requests = {
  my_certificate_key = {
    name         = "my-certificate"
    keyvault_key = "my_keyvault_key"

    certificate_policy = {
      issuer_key_or_name  = "self"  # or certificate authority name
      exportable          = true
      key_size            = 2048    # 2048, 3072, or 4096
      key_type            = "RSA"
      reuse_key           = true
      renewal_action      = "AutoRenew"  # or "EmailContacts"
      lifetime_percentage = 90
      content_type        = "application/x-pkcs12"

      x509_certificate_properties = {
        extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
        key_usage = [
          "cRLSign",
          "dataEncipherment",
          "digitalSignature",
          "keyAgreement",
          "keyCertSign",
          "keyEncipherment",
        ]

        subject_alternative_names = {
          dns_names = ["example.com", "www.example.com"]
          emails    = []
          upns      = []
        }

        subject            = "CN=example.com"
        validity_in_months = 12
      }
    }

    tags = {
      purpose = "ssl-certificate"
    }
  }
}
```

### Managed Identity Configuration

For secure access to Key Vault certificates, configure managed identities:

```hcl
managed_identities = {
  my_service_identity = {
    name               = "my-service-identity"
    resource_group_key = "my_rg"

    tags = {
      purpose = "service-authentication"
    }
  }
}
```

### Key Vault Access Pattern (RBAC Recommended)

Configure Key Vault with RBAC authorization for better security and modern patterns:

#### ✅ Recommended: RBAC Pattern

```hcl
keyvaults = {
  my_kv = {
    name               = "my-keyvault"
    resource_group_key = "my_rg"
    sku_name           = "standard"
    soft_delete_enabled = true
    
    # Enable RBAC authorization (recommended)
    enable_rbac_authorization = true

    creation_policies = {
      logged_in_user = {
        certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover", "GetIssuers", "SetIssuers", "ListIssuers", "DeleteIssuers", "ManageIssuers", "Restore", "ManageContacts"]
        key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"]
        secret_permissions      = ["Set", "Get", "List", "Delete", "Purge", "Recover", "Backup", "Restore"]
      }
    }
  }
}

# RBAC role assignments (separate file: role_mapping.tfvars)
role_mapping = {
  built_in_role_mapping = {
    keyvaults = {
      my_kv = {
        # Current user/service principal needs admin access to manage certificates
        "Key Vault Administrator" = {
          logged_in = {
            keys = ["user"]
          }
        }
        "Key Vault Certificates User" = {
          managed_identities = {
            keys = ["my_service_identity"]
          }
        }
        "Key Vault Secrets User" = {
          managed_identities = {
            keys = ["my_service_identity"]
          }
        }
      }
    }
  }
}
```

#### ⚠️ Legacy: Access Policies Pattern (for backwards compatibility)

```hcl
keyvaults = {
  my_kv = {
    name               = "my-keyvault"
    resource_group_key = "my_rg"
    sku_name           = "standard"
    soft_delete_enabled = true

    creation_policies = {
      logged_in_user = {
        certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"]
        key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"]
        secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
      }
    }
  }
}

# Separate access policies (legacy pattern)
keyvault_access_policies = {
  my_kv = {
    my_service_identity = {
      managed_identity_key    = "my_service_identity"
      certificate_permissions = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
    }
  }
}
```

**RBAC vs Access Policies:**

| Feature | RBAC (Recommended) | Access Policies (Legacy) |
|---------|-------------------|-------------------------|
| Security | ✅ More granular with built-in roles | ⚠️ Manual permission sets |
| Azure AD Integration | ✅ Full integration | ❌ Limited |
| Conditional Access | ✅ Supported | ❌ Not supported |
| Audit & Compliance | ✅ Better audit trails | ⚠️ Basic logging |
| Microsoft Recommendation | ✅ Current best practice | ⚠️ Legacy approach |
| Future Support | ✅ Actively developed | ⚠️ Maintenance mode |

### Certificate Resolution in Module Resources

In module resource files, use the `coalesce(try(...))` pattern:

```hcl
resource "azurerm_cdn_frontdoor_secret" "secret" {
  name                     = azurecaf_name.secret.result
  cdn_frontdoor_profile_id = var.remote_objects.cdn_frontdoor_profile.id

  dynamic "secret" {
    for_each = try(var.settings.secret, {}) != {} ? [var.settings.secret] : []

    content {
      dynamic "customer_certificate" {
        for_each = try(secret.value.customer_certificate, {}) != {} ? [secret.value.customer_certificate] : []

        content {
          key_vault_certificate_id = coalesce(
            try(var.settings.secret.customer_certificate.key_vault_certificate_id, null),
            try(var.remote_objects.keyvault_certificate_requests[try(var.settings.secret.customer_certificate.certificate_request.lz_key, var.client_config.landingzone_key)][var.settings.secret.customer_certificate.certificate_request.key].secret_id, null),
            try(var.remote_objects.keyvault_certificates[try(var.settings.secret.customer_certificate.keyvault_certificate.lz_key, var.client_config.landingzone_key)][var.settings.secret.customer_certificate.keyvault_certificate.key].secret_id, null)
          )
        }
      }
    }
  }
}
```

### Root Module Remote Objects Configuration

Ensure the parent module passes necessary remote objects:

```hcl
module "my_service" {
  source   = "./modules/category/my_service"
  for_each = local.category.my_service

  # ... standard variables ...

  remote_objects = {
    diagnostics                   = local.combined_diagnostics
    keyvault_certificate_requests = local.combined_objects_keyvault_certificate_requests
    managed_identities           = local.combined_objects_managed_identities
    keyvaults                    = local.combined_objects_keyvaults
  }
}
```

### Modular Configuration with Multiple `.tfvars` Files

For complex configurations involving certificates, organize into separate files:

#### `resource_groups.tfvars`

```hcl
resource_groups = {
  my_rg = {
    name     = "rg-my-service"
    location = "West Europe"
    tags = {
      environment = "production"
    }
  }
}
```

#### `keyvaults.tfvars`

```hcl
keyvaults = {
  # Key Vault configuration as shown above
}

keyvault_certificate_requests = {
  # Certificate requests as shown above
}
```

#### `managed_identities.tfvars`

```hcl
managed_identities = {
  # Managed identity configuration as shown above
}
```

#### `configuration.tfvars`

```hcl
my_services = {
  service1 = {
    name               = "my-service"
    resource_group_key = "my_rg"

    secrets = {
      ssl_cert = {
        name = "ssl-certificate"
        secret = {
          customer_certificate = {
            certificate_request = {
              key = "my_certificate_key"
            }
          }
        }
      }
    }
  }
}
```

### Usage Commands

Deploy with multiple configuration files:

```bash
terraform plan \
  -var-file=./category/service/level-example/resource_groups.tfvars \
  -var-file=./category/service/level-example/keyvaults.tfvars \
  -var-file=./category/service/level-example/managed_identities.tfvars \
  -var-file=./category/service/level-example/configuration.tfvars
```

### Documentation

- Update the root `/examples/README.md` to include information about new module example structures or significant scenarios if necessary.
- The primary documentation for a module's examples should reside in `examples/<category_name>/<module_name>/README.md`.
- Ensure that the documentation is clear, concise, and provides enough context for users to understand how to use the examples effectively.

### Modify existing files

#### /local.remote_objects.tf

Insert alphabetically the following code to the file inside of locals { }:

module_names = try(local.combined_objects_module_names, null)

Example with module_nameequal to resource_groups:

```hcl
network_managers                               = try(local.combined_objects_network_managers, null)
```

#### /locals.combined_objects.tf

Insert alphabetically the following code to the file inside of locals { }:

combined_objects_module_names = merge(tomap({ (local.client_config.landingzone_key) = module.module_names }), lookup(var.remote_objects, "module_names", {}), lookup(var.data_sources, "module_names", {}))

Example with module_name equal to resource_groups:

```hcl
combined_objects_network_managers                               = merge(tomap({ (local.client_config.landingzone_key) = module.network_managers }), lookup(var.remote_objects, "network_managers", {}), lookup(var.data_sources, "network_managers", {}))
```

#### /locals.tf

Add the following code to the file inside of locals { }:

category_name = {
module_name = try(var.category.module_name, {})
}

Example with module_name equal to resource_groups and category_name equal to dynamic_app_config_combined_objects:

```hcl
locals {
  dynamic_app_config_combined_objects = {
    resource_groups = try(var.dynamic_app_config_combined_objects.resource_groups, {})
  }
}
```

Example with category_name equal to cognitive_services and module_name cognitive_services_account:

```hcl
locals {
  cognitive_services = {
    cognitive_services_account = try(var.cognitive_services.cognitive_services_account, {})
  }
}
```

#### /category_name_module_names.tf

Add the following code to the file:

```hcl
module "module_names" {
  source   = "./modules/category_name/module_name"
  for_each = local.category_name.module_name

  client_config   = local.client_config
  global_settings = local.global_settings
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  base_tags       = local.global_settings.inherit_tags
  location        = try(each.value.location, null)
  settings        = each.value

  remote_objects = {
    module_that_depends_on = local.combined_objects_module_that_depends_on
  }
}

output "module_names" {
  value = module.module_name
}
```

#### /modules/category_name/module_name/module_name.tf

Add the following code to the file:

```hcl
resource "azurerm_module_name" "module_name" {
  name                = var.settings.name
  location            = local.location
  resource_group_name = local.resource_group_name
  # Other arguments

}
```

#### /modules/category_name/module_name/locals.tf

Add the following code to the file:

```hcl
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = var.base_tags ? merge(
    var.global_settings.tags,
    try(var.resource_group.tags, null),
    local.module_tag,
    try(var.settings.tags, null)
    ) : merge(
    local.module_tag,
    try(var.settings.tags,
    null)
  )
  location            = coalesce(var.location, var.resource_group.location)
  resource_group_name = var.resource_group.name

}
```

#### /modules/category_name/module_name/outputs.tf

Add the following code to the file:

```hcl

output "id" {
  value = azurerm_module_name.module_name.id
}

output "attribute_name" {
  value = azurerm_module_name.module_name.attribute_name
}
```

For example for resource container_app with name container_app:

In addition to the Arguments listed above - the following Attributes are exported:

id - The ID of the Container App.

custom_domain_verification_id - The ID of the Custom Domain Verification for this Container App.

This would be added to the outputs.tf file:

```hcl
output "id" {
  value = azurerm_container_app.container_app.id
}

output "custom_domain_verification_id" {
  value = azurerm_container_app.container_app.custom_domain_verification_id
}
```

#### /modules/category_name/module_name/providers.tf

Add the following code to the file:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.1.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}
```

#### /modules/category_name/module_name/variables.tf

Add the following code to the file:

```hcl
## Global settings
variable "global_settings" {
  description = <<DESCRIPTION
  The global_settings object is a map of settings that can be used to configure the naming convention for Azure resources. It allows you to specify a default region, environment, and other settings that will be used when generating names for resources.
  Any non-compliant characters will be removed from the name, suffix, or prefix. The generated name will be compliant with the set of allowed characters for each Azure resource type.
  These are the settings that can be configured:
  - default_region - (Optional) The default region to use for the global settings object, by default it is set to "region1".
  - environment - (Optional) The environment to use for deployments.
  - inherit_tags - (Optional) A boolean value that indicates whether to inherit tags from the global settings object and from the resource group, by default it is set to false.
  - prefix - (Optional) The prefix to append as the first characters of the generated name. The prefix will be separated by the separator character.
  - suffix - (Optional) The suffix to append after the basename of the resource to create. The suffix will be separated by the separator character.
  - prefix_with_hyphen - (Optional) A boolean value that indicates whether to add a hyphen to the prefix.
  - prefixes - (Optional) A list of prefixes to append as the first characters of the generated name. The prefixes will be separated by the separator character.
  - suffixes - (Optional) A list of suffixes to append after the basename of the resource to create. The suffixes will be separated by the separator character.
  - random_length - (Optional) The length of the random string to generate. Defaults to 0.
  - random_seed - (Optional) The seed to be used for the random generator. 0 will not be respected and will generate a seed based on the Unix time of the generation.
  - resource_type - (Optional) The type of Azure resource you are requesting a name from (e.g., Azure Container Registry: azurerm_container_registry). See the Resource Types supported: https://github.com/aztfmod/terraform-provider-azurecaf?tab=readme-ov-file#resource-status.
  - resource_types - (Optional) A list of additional resource types should you want to use the same settings for a set of resources.
  - separator - (Optional) The separator character to use between prefixes, resource type, name, suffixes, and random characters. Defaults to "-".
  - passthrough - (Optional) A boolean value that indicates whether to pass through the naming convention. In that case only the clean input option is considered and the prefixes, suffixes, random, and are ignored. The resource prefixe is not added either to the resulting string. Defaults to false.
  - regions - (Optional) A map of regions to use for the global settings object.
    - region1 - The name of the first region.
    - region2 - The name of the second region.
    - regionN - The name of the Nth region.
  - tags - (Optional) A map of tags to be inherited from the global settings object if inherit_tags is set to true.
  - clean_input - (Optional) A boolean value that indicates whether to remove non-compliant characters from the name, suffix, or prefix. Defaults to true.
  - use_slug - (Optional) A boolean value that indicates whether a slug should be added to the name. Defaults to true.
DESCRIPTION
  type        = any
  /*type = object({
    default_region     = optional(string)
    environment        = optional(string)
    inherit_tags       = optional(bool)
    prefix             = optional(string)
    suffix             = optional(string)
    prefix_with_hyphen = optional(bool)
    prefixes           = optional(list(string))
    suffixes           = optional(list(string))
    random_length      = optional(number)
    random_seed        = optional(number)
    resource_type      = optional(string)
    resource_types     = optional(list(string))
    separator          = optional(string)
    clean_input        = optional(bool)
    passthrough        = optional(bool)
    regions            = map(string)
    use_slug           = optional(bool)
  })*/
}
## Client configuration

variable "client_config" {

  description = <<DESCRIPTION
    Client configuration object primarily used for specifying the Azure client context in non-interactive environments,
    such as CI/CD pipelines running under a Service Principal.

    If this variable is left as an empty map (the default), the module will attempt to derive the client configuration
    (like client_id, tenant_id, subscription_id, object_id) from the current Azure provider context
    (e.g., credentials from Azure CLI, VS Code Azure login, or environment variables).

    If you provide a map, it should contain the necessary authentication and context details. The structure used
    when the default is derived includes keys like:
    - client_id
    - landingzone_key
    - logged_aad_app_objectId
    - logged_user_objectId
    - object_id
    - subscription_id
    - tenant_id

    Example of providing explicit configuration (e.g., for a Service Principal):
    client_config = {
      client_id       = "your-service-principal-client-id"
      object_id       = "your-service-principal-object-id"
      subscription_id = "your-target-subscription-id"
      tenant_id       = "your-azure-ad-tenant-id"
      landingzone_key = "my_landingzone" # Optional, defaults to var.current_landingzone_key if needed elsewhere
      # Add other relevant keys if needed by the specific module context
    }
  DESCRIPTION
  type        = any

  /*type = object({
    client_id       = optional(string)
    landingzone_key = optional(string)
    logged_aad_app_objectId = optional(string)
    logged_user_objectId = optional(string)
    object_id       = optional(string)
    subscription_id = optional(string)
    tenant_id       = optional(string)
  })*/

}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
# Complete the rest of settings in variable settings
variable "settings" {
  description = <<DESCRIPTION
  Settings of the module:

  DESCRIPTION
  type        = any

}

variable "resource_group" {
  description = "Resource group object"
  type        = any
}

variable "base_tags" {
  type        = bool
  description = "Flag to determine if tags should be inherited"
}

variable "remote_objects" {
  type        = any
  description = "Remote objects"
}

```

#### /modules/category_name/module_name/diagnostics.tf

Add the following code to the file:

```hcl
module "diagnostics" {
  source = "../../diagnostics"
  count  = lookup(var.settings, "diagnostic_profiles", null) == null ? 0 : 1

  resource_id       = azurerm_module_name.module_name.id
  resource_location = azurerm_module_name.module_name.location
  diagnostics       = var.remote_objects.diagnostics
  profiles          = var.settings.diagnostic_profiles
}
```

#### /modules/category_name/module_name/main.tf

Add the following code to the file:

```hcl
#This file is maintained by legacy purposes. Please do not modify this file.
```

#### /modules/category_name/module_name/managed_identitties.tf

Add the following code to the file:

```hcl
#
# Managed identities from remote state
#

locals {
  managed_local_identities = flatten([
    for managed_identity_key in try(var.settings.identity.managed_identity_keys, []) : [
      var.remote_objects.managed_identities[var.client_config.landingzone_key][managed_identity_key].id
    ]
  ])

  managed_remote_identities = flatten([
    for lz_key, value in try(var.settings.identity.remote, []) : [
      for managed_identity_key in value.managed_identity_keys : [
        var.remote_objects.managed_identities[lz_key][managed_identity_key].id
      ]
    ]
  ])

  managed_identities = concat(local.managed_local_identities, local.managed_remote_identities)
}
```

## Submodule Dependency Pattern

When creating modules with multiple submodules (subresources), follow the established pattern used by modules like `network_manager` and `cdn_frontdoor_profile`. This pattern ensures proper dependency management and consistency across the CAF framework.

### Key Principles

1. **All dependencies between submodules must be passed through `var.remote_objects`**
2. **Never pass resource IDs directly as separate variables between modules**
3. **Use `coalesce()` with `try()` pattern to resolve resource dependencies**
4. **Use pluralized names for module calls (e.g., `endpoints`, `origins`, not `endpoint`, `origin`)**

### Pattern Implementation

#### Parent Module Submodule Calls

In the parent module, call submodules using this pattern:

```hcl
# Example: calling endpoints submodule
module "endpoints" {
  source   = "./endpoint"
  for_each = try(var.settings.endpoints, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_profile = azurerm_cdn_frontdoor_profile.cdn_frontdoor_profile
  })
}

# Example: calling origins submodule that depends on origin_groups
module "origins" {
  source   = "./origin"
  for_each = try(var.settings.origins, {})

  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = var.base_tags
  settings        = each.value

  remote_objects = merge(var.remote_objects, {
    cdn_frontdoor_origin_groups = module.origin_groups
  })

  depends_on = [module.origin_groups]
}
```

#### Submodule Variables

Submodule `variables.tf` files should only contain the standard variables:

```hcl
variable "global_settings" {
  description = "Global settings for naming conventions and tags."
  type        = any
}

variable "client_config" {
  description = "Client configuration for Azure authentication."
  type        = any
}

variable "location" {
  description = "Specifies the Azure location where the resource will be created."
  type        = string
}

variable "settings" {
  description = "Configuration settings for the resource."
  type        = any
}

variable "resource_group" {
  description = "Resource group object."
  type        = any
}

variable "base_tags" {
  description = "Flag to determine if tags should be inherited."
  type        = bool
}

variable "remote_objects" {
  description = "Remote objects for dependencies."
  type        = any
}
```

**❌ DO NOT include direct ID variables like:**

- `variable "cdn_frontdoor_profile_id"`
- `variable "origin_groups"`
- `variable "rule_sets"`

#### Submodule Resource Implementation

In submodule resources, use the `coalesce()` pattern to resolve dependencies:

```hcl
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name = var.settings.name
  cdn_frontdoor_profile_id = coalesce(
    try(var.settings.cdn_frontdoor_profile_id, null),
    try(var.remote_objects.cdn_frontdoor_profile.id, null),
    try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
  )
  enabled = try(var.settings.enabled, true)

  # ... other configuration
}

# Example with dependency on other submodule
resource "azurerm_cdn_frontdoor_origin" "origin" {
  name = var.settings.name
  cdn_frontdoor_origin_group_id = coalesce(
    try(var.settings.cdn_frontdoor_origin_group_id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
    try(var.remote_objects.cdn_frontdoor_origin_groups[try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)][var.settings.origin_group.key].id, null)
  )

  # ... other configuration
}
```

#### Parent Module Outputs

Use pluralized names in outputs:

```hcl
output "endpoints" {
  value = module.endpoints
}

output "origin_groups" {
  value = module.origin_groups
}

output "origins" {
  value = module.origins
}
```

### Benefits of This Pattern

1. **Consistency**: All modules follow the same dependency resolution pattern
2. **Flexibility**: Resources can be referenced by direct ID or by key lookup
3. **Maintainability**: Clear separation of concerns between modules
4. **Scalability**: Supports complex dependency chains between submodules
5. **CAF Compliance**: Aligns with the established Cloud Adoption Framework standards

### Example Reference Modules

- `modules/networking/network_manager` - Reference implementation
- `modules/cdn/cdn_frontdoor_profile` - Recently refactored to follow this pattern

## Key Vault Certificates and Managed Identity Pattern

When working with modules that require SSL/TLS certificates from Key Vault, follow these established patterns for security, maintainability, and CAF compliance.

### Key Principles

1. **Always use certificate keys instead of direct Key Vault certificate IDs**
2. **Use managed identities for secure access to Key Vault**
3. **Separate configuration concerns into multiple `.tfvars` files**
4. **Follow the `coalesce(try(...))` pattern for certificate resolution**

### Certificate Reference Pattern

#### ❌ DO NOT use direct certificate IDs:

```hcl
# Wrong approach - direct ID
secrets = {
  secret1 = {
    name = "my-secret"
    secret = {
      customer_certificate = {
        key_vault_certificate_id = "/subscriptions/.../certificates/cert1"
      }
    }
  }
}
```

#### ✅ DO use certificate keys with proper resolution:

```hcl
# Correct approach - key reference
secrets = {
  secret1 = {
    name = "my-secret"
    secret = {
      customer_certificate = {
        certificate_request = {
          key = "my_certificate_key"
          # lz_key = "remote_lz"  # Optional for remote landing zone
        }
      }
    }
  }
}
```

### Key Vault Certificate Request Structure

Use this structure for `keyvault_certificate_requests`:

```hcl
keyvault_certificate_requests = {
  my_certificate_key = {
    name         = "my-certificate"
    keyvault_key = "my_keyvault_key"

    certificate_policy = {
      issuer_key_or_name  = "self"  # or certificate authority name
      exportable          = true
      key_size            = 2048    # 2048, 3072, or 4096
      key_type            = "RSA"
      reuse_key           = true
      renewal_action      = "AutoRenew"  # or "EmailContacts"
      lifetime_percentage = 90
      content_type        = "application/x-pkcs12"

      x509_certificate_properties = {
        extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
        key_usage = [
          "cRLSign",
          "dataEncipherment",
          "digitalSignature",
          "keyAgreement",
          "keyCertSign",
          "keyEncipherment",
        ]

        subject_alternative_names = {
          dns_names = ["example.com", "www.example.com"]
          emails    = []
          upns      = []
        }

        subject            = "CN=example.com"
        validity_in_months = 12
      }
    }

    tags = {
      purpose = "ssl-certificate"
    }
  }
}
```

### Managed Identity Configuration

For secure access to Key Vault certificates, configure managed identities:

```hcl
managed_identities = {
  my_service_identity = {
    name               = "my-service-identity"
    resource_group_key = "my_rg"

    tags = {
      purpose = "service-authentication"
    }
  }
}
```

## Azure Front Door and WAF Patterns

When working with Azure Front Door and Web Application Firewall (WAF), follow these established patterns for security, performance, and CAF compliance.

### Front Door Resource Dependencies

Front Door resources have specific dependency requirements that must be managed carefully:

#### Critical Dependency Order

1. **Profile** → **Origin Groups** → **Origins** → **Endpoints** → **Routes**
2. **WAF Policy** → **Security Policy** (links WAF to domains/endpoints)
3. **Custom Domains** → **Routes** (routes reference domains)

#### Lifecycle Management for Front Door

Use `create_before_destroy` for resources that may need replacement:

```hcl
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  # ... configuration ...

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_cdn_frontdoor_origin" "origin" {
  # ... configuration ...

  lifecycle {
    create_before_destroy = true
  }
}
```

#### Explicit Dependencies in Parent Modules

Ensure proper destruction order in parent modules:

```hcl
module "origins" {
  source = "./origin"
  # ... configuration ...

  depends_on = [module.origin_groups]
}

module "routes" {
  source = "./route"
  # ... configuration ...

  depends_on = [module.endpoints, module.origins, module.origin_groups]
}
```

### WAF Policy Configuration

#### Standard WAF Policy Structure

```hcl
resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
  name                = azurecaf_name.waf_policy.result
  resource_group_name = local.resource_group_name
  sku_name            = var.settings.sku_name  # Must match Front Door profile SKU
  enabled             = try(var.settings.enabled, true)
  mode                = try(var.settings.mode, "Prevention")

  # Managed rules are essential for security
  dynamic "managed_rule" {
    for_each = try(var.settings.managed_rules, {})
    content {
      type    = managed_rule.value.type
      version = managed_rule.value.version
      action  = try(managed_rule.value.action, "Block")

      dynamic "exclusion" {
        for_each = try(managed_rule.value.exclusions, {})
        content {
          match_variable = exclusion.value.match_variable
          operator       = exclusion.value.operator
          selector       = exclusion.value.selector
        }
      }

      dynamic "override" {
        for_each = try(managed_rule.value.overrides, {})
        content {
          rule_group_name = override.value.rule_group_name

          dynamic "rule" {
            for_each = try(override.value.rules, {})
            content {
              rule_id = rule.value.rule_id
              action  = rule.value.action
              enabled = try(rule.value.enabled, true)
            }
          }
        }
      }
    }
  }

  # Custom rules for specific requirements
  dynamic "custom_rule" {
    for_each = try(var.settings.custom_rules, {})
    content {
      name     = custom_rule.value.name
      action   = custom_rule.value.action
      enabled  = try(custom_rule.value.enabled, true)
      priority = custom_rule.value.priority
      type     = custom_rule.value.type

      dynamic "match_condition" {
        for_each = custom_rule.value.match_conditions
        content {
          match_variable     = match_condition.value.match_variable
          match_values       = match_condition.value.match_values
          operator           = match_condition.value.operator
          selector           = try(match_condition.value.selector, null)
          negation_condition = try(match_condition.value.negation_condition, false)
          transforms         = try(match_condition.value.transforms, [])
        }
      }
    }
  }
}
```

#### WAF Policy Best Practices

1. **SKU Compatibility**: WAF policy SKU must match Front Door profile SKU (`Standard_AzureFrontDoor` or `Premium_AzureFrontDoor`)
2. **Managed Rules**: Always include Microsoft_DefaultRuleSet and Microsoft_BotManagerRuleSet
3. **Custom Rules**: Use for application-specific security requirements
4. **Exclusions**: Configure carefully to avoid false positives
5. **Testing**: Use "Detection" mode first, then switch to "Prevention"

### Front Door Custom Domain with Certificates

#### Certificate Resolution Pattern

```hcl
resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  name                     = azurecaf_name.custom_domain.result
  cdn_frontdoor_profile_id = var.remote_objects.cdn_frontdoor_profile.id
  dns_zone_id              = try(var.settings.dns_zone_id, null)
  host_name                = var.settings.host_name

  dynamic "tls" {
    for_each = try(var.settings.tls, null) == null ? [] : [var.settings.tls]
    content {
      certificate_type    = try(tls.value.certificate_type, "ManagedCertificate")
      minimum_tls_version = try(tls.value.minimum_tls_version, "TLS12")

      # Certificate resolution using coalesce pattern
      cdn_frontdoor_secret_id = tls.value.certificate_type == "CustomerCertificate" ? coalesce(
        try(tls.value.cdn_frontdoor_secret_id, null),
        try(var.remote_objects.cdn_frontdoor_secrets[try(tls.value.secret.lz_key, var.client_config.landingzone_key)][tls.value.secret.key].id, null)
      ) : null
    }
  }
}
```

#### DNS Validation Token Output

Always expose DNS validation tokens for certificate validation:

```hcl
output "dns_validation_token" {
  value       = azurerm_cdn_frontdoor_custom_domain.custom_domain.validation_token
  description = "DNS validation token for custom domain certificate validation"
}

output "id" {
  value       = azurerm_cdn_frontdoor_custom_domain.custom_domain.id
  description = "The ID of the Front Door custom domain"
}
```

### Security Policy Linking

Link WAF policies to Front Door domains using security policies:

```hcl
resource "azurerm_cdn_frontdoor_security_policy" "security_policy" {
  name                     = azurecaf_name.security_policy.result
  cdn_frontdoor_profile_id = var.remote_objects.cdn_frontdoor_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = coalesce(
        try(var.settings.firewall_policy_id, null),
        try(var.remote_objects.cdn_frontdoor_firewall_policies[try(var.settings.firewall_policy.lz_key, var.client_config.landingzone_key)][var.settings.firewall_policy.key].id, null)
      )

      association {
        # Link to custom domains
        dynamic "domain" {
          for_each = try(var.settings.domains, [])
          content {
            cdn_frontdoor_domain_id = coalesce(
              try(domain.value.cdn_frontdoor_domain_id, null),
              try(var.remote_objects.cdn_frontdoor_custom_domains[try(domain.value.lz_key, var.client_config.landingzone_key)][domain.value.key].id, null)
            )
          }
        }

        # Link to endpoints
        dynamic "domain" {
          for_each = try(var.settings.endpoints, [])
          content {
            cdn_frontdoor_domain_id = coalesce(
              try(domain.value.cdn_frontdoor_domain_id, null),
              try(var.remote_objects.cdn_frontdoor_endpoints[try(domain.value.lz_key, var.client_config.landingzone_key)][domain.value.key].id, null)
            )
          }
        }

        patterns_to_match = try(var.settings.patterns_to_match, ["/*"])
      }
    }
  }
}
```

### Front Door Common Issues and Solutions

#### SKU Mismatch Resolution

**Problem**: WAF policy SKU doesn't match Front Door profile SKU
**Solution**: Ensure both resources use the same SKU tier

```hcl
# Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "profile" {
  sku_name = "Premium_AzureFrontDoor"  # or "Standard_AzureFrontDoor"
}

# WAF Policy must match
resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  sku_name = "Premium_AzureFrontDoor"  # Must match profile SKU
}
```

#### Certificate Validation Issues

**Problem**: Custom domain certificate validation fails
**Solution**: Properly configure DNS validation tokens

```hcl
# Output validation token for DNS configuration
output "dns_validation_token" {
  value = azurerm_cdn_frontdoor_custom_domain.custom_domain.validation_token
}

# DNS record for validation (external to Terraform)
# Create DNS TXT record: _dnsauth.yourdomain.com -> validation_token
```

#### Resource Destruction Order

**Problem**: Resources fail to destroy due to dependencies
**Solution**: Use lifecycle rules and explicit dependencies

```hcl
# In parent module
depends_on = [module.routes, module.security_policies]

# In resources
lifecycle {
  create_before_destroy = true
}
```

## Code Style

### Necessary Blocks

Use the following structure for necessary blocks:

```hcl
block_name {
    argument_name = var.settings.argument_name
}
```

### Dependency Resolution Pattern

When resolving dependencies to other resources (especially between submodules), always use the `coalesce()` pattern with `try()` functions to support multiple ways of providing resource IDs:

#### Standard Pattern for Resource ID Resolution

```hcl
resource_id = coalesce(
  try(var.settings.direct_resource_id, null),
  try(var.remote_objects.resource_name.id, null),
  try(var.remote_objects.resource_names[try(var.settings.resource_reference.lz_key, var.client_config.landingzone_key)][var.settings.resource_reference.key].id, null)
)
```

#### Examples

**Profile ID Resolution:**

```hcl
cdn_frontdoor_profile_id = coalesce(
  try(var.settings.cdn_frontdoor_profile_id, null),
  try(var.remote_objects.cdn_frontdoor_profile.id, null),
  try(var.remote_objects.cdn_frontdoor_profiles[try(var.settings.cdn_frontdoor_profile.lz_key, var.client_config.landingzone_key)][var.settings.cdn_frontdoor_profile.key].id, null)
)
```

**Origin Group ID Resolution:**

```hcl
cdn_frontdoor_origin_group_id = coalesce(
  try(var.settings.cdn_frontdoor_origin_group_id, null),
  try(var.remote_objects.cdn_frontdoor_origin_groups[var.settings.origin_group_key].id, null),
  try(var.remote_objects.cdn_frontdoor_origin_groups[try(var.settings.origin_group.lz_key, var.client_config.landingzone_key)][var.settings.origin_group.key].id, null)
)
```

**Service Plan ID Resolution:**

```hcl
service_plan_id = coalesce(
    try(var.settings.service_plan_id, null),
    try(var.remote_objects.service_plans[try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null),
    try(var.remote_objects.app_service_plans[try(var.settings.app_service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_plan.key, var.settings.app_service_plan_key)].id, null)
  )
```

#### Benefits of This Pattern

1. **Flexibility**: Supports direct ID passing, current module references, and cross-landing zone references
2. **Backward Compatibility**: Maintains support for existing configuration patterns
3. **Consistency**: Standardized approach across all CAF modules
4. **Error Prevention**: Graceful handling of missing or null values

### Resource Lifecycle Management

When working with resources that have complex dependencies or need specific creation/destruction order, use these patterns:

#### Create Before Destroy Pattern

For resources that may need to be replaced and have dependent resources, use `create_before_destroy`:

```hcl
resource "azurerm_resource_type" "resource_name" {
  # ... configuration ...

  lifecycle {
    create_before_destroy = true
  }
}
```

**When to use:**
- Resources that are referenced by other resources
- Resources that cannot have downtime during replacement
- Resources with complex dependencies (e.g., Front Door origins, origin groups)

#### Explicit Dependencies

Use `depends_on` in parent modules to ensure proper destruction order:

```hcl
module "dependent_resource" {
  source = "./submodule"
  # ... configuration ...

  depends_on = [module.prerequisite_resource]
}
```

**When to use:**
- When Terraform cannot automatically detect dependencies
- When destruction order is critical
- When submodules have circular or complex dependencies

#### Prevent Destroy Pattern

For critical resources that should never be accidentally destroyed:

```hcl
resource "azurerm_resource_type" "critical_resource" {
  # ... configuration ...

  lifecycle {
    prevent_destroy = true
  }
}
```

**When to use:**
- Production databases
- Key Vaults with critical secrets
- Networking resources that would cause widespread outages

### Module Integration and Wiring Patterns

When adding new modules to the CAF framework, follow these integration patterns:

#### CAF Module Integration Checklist

1. **Add module variable to `examples/variables.tf`**:
   ```hcl
   variable "new_module_name" {
     description = "Configuration for new module"
     type        = any
     default     = {}
   }
   ```

2. **Add module call to `examples/module.tf`**:
   ```hcl
   module "new_module_name" {
     source   = "../modules/category/new_module"
     for_each = local.category.new_module_name

     # Standard variables
     global_settings = local.global_settings
     client_config   = local.client_config
     # ... other standard variables

     remote_objects = {
       # Required remote objects
     }
   }
   ```

3. **Add to `locals.tf`**:
   ```hcl
   locals {
     category = {
       new_module_name = try(var.category.new_module_name, {})
     }
   }
   ```

4. **Add combined objects to `locals.combined_objects.tf`**:
   ```hcl
   combined_objects_new_module_name = merge(
     tomap({ (local.client_config.landingzone_key) = module.new_module_name }),
     lookup(var.remote_objects, "new_module_name", {}),
     lookup(var.data_sources, "new_module_name", {})
   )
   ```

5. **Add to `local.remote_objects.tf`**:
   ```hcl
   new_module_name = try(local.combined_objects_new_module_name, null)
   ```

6. **Create root module file `category_new_module_name.tf`**:
   ```hcl
   module "new_module_name" {
     source   = "./modules/category/new_module"
     for_each = local.category.new_module_name

     # Standard configuration
   }

   output "new_module_name" {
     value = module.new_module_name
   }
   ```

### Migration from Deprecated Resources

When migrating from deprecated Azure resources to their modern equivalents:

#### Common Migration Patterns

**App Service Migration:**
```hcl
# ❌ Deprecated - DO NOT USE
resource "azurerm_app_service" "example" {
  # ... configuration
}

# ✅ Modern - USE INSTEAD
resource "azurerm_linux_web_app" "example" {
  # ... configuration
}
# OR
resource "azurerm_windows_web_app" "example" {
  # ... configuration
}
```

**Front Door Migration:**
```hcl
# ❌ Deprecated - DO NOT USE
resource "azurerm_frontdoor" "example" {
  # ... configuration
}

# ✅ Modern - USE INSTEAD
resource "azurerm_cdn_frontdoor_profile" "example" {
  # ... configuration
}
```

#### Migration Best Practices

1. **Always check the Azure provider documentation** for the latest resource schemas
2. **Use MCP Terraform tools** to verify resource arguments and best practices
3. **Update examples** to use modern resources only
4. **Maintain backward compatibility** where possible using the coalesce pattern
5. **Document breaking changes** in module documentation and changelogs

### Example Testing Pattern

When creating or updating examples, follow these critical testing patterns:

#### Example Structure Requirements

1. **All examples must be tested from the `/examples` directory**
2. **Examples must use the root CAF module, not custom `main.tf` files**
3. **Examples must include all required CAF framework wiring**
4. **Examples must demonstrate real-world scenarios**

#### Testing Commands

```bash
# Navigate to examples directory
cd /path/to/terraform-azurerm-caf/examples

# Test example with specific configuration
terraform init
terraform plan -var-file=./category/module/scenario/configuration.tfvars
terraform apply -var-file=./category/module/scenario/configuration.tfvars
terraform destroy -var-file=./category/module/scenario/configuration.tfvars
```

#### Example Configuration Pattern

Examples should be organized as:
```
examples/
└── category/
    └── module_name/
        └── scenario/
            ├── README.md
            ├── configuration.tfvars
            ├── resource_groups.tfvars (if needed)
            ├── keyvaults.tfvars (if needed)
            └── managed_identities.tfvars (if needed)
```

#### Example Documentation

Each example must have a `README.md` that includes:
- Purpose and use case
- Prerequisites and dependencies
- Step-by-step deployment instructions
- Expected outputs and validation steps
- Cleanup instructions

### Dynamic Blocks

These are the recommended patterns for creating configuration blocks dynamically and optionally in Terraform.

#### Optional Single Block

Used when a configuration block can exist zero or one time. The controlling variable (`var.settings.block` in this case) should be an object that can be `null`.

```hcl
dynamic "block" {
  # This pattern creates a list with 0 or 1 element.
  # It's the clearest way to handle a single optional block.
  for_each = var.settings.block == null ? [] : [var.settings.block]

  content {
    # Since there's only one element, its content is accessed with "block.value".
    name  = block.value.name
    value = block.value.value
  }
}
```

#### Optional Multiple Blocks (from a List)

Used to create multiple blocks from a list of objects (`list(object)`). This is ideal when the order of the blocks is important and they are identified by their position.

```hcl
dynamic "block" {
  # Iterates over the list. If the variable is null, "try" converts it
  # into an empty list [] so that no block is generated.
  for_each = try(var.settings.block, [])

  content {
    # "block.value" represents each object within the list.
    name  = block.value.name
    value = block.value.value
  }
}
```

#### Optional Multiple Blocks (from a Map)

Used to create multiple blocks from a map of objects (`map(object)`). It's the best option when each block needs a unique and stable identifier (the map key) and the order is not important.

```hcl
dynamic "block" {
  # Iterates over the map. If the variable is null, "try" converts it
  # into an empty map {} so that no block is generated.
  for_each = try(var.settings.block, {})

  content {
    # "block.key" is the unique identifier for each element (the map key).
    # "block.value" is the object associated with that key.
    name  = block.key
    value = block.value.value
  }
}
```

#### dynamic block identity

Use the following structure for dynamic block identity:

```hcl
  dynamic "identity" {
    for_each = try(var.settings.identity, null) == null ? [] : [var.settings.identity]

    content {
      type         = var.settings.identity.type
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.settings.identity.type)) ? local.managed_identities : null
    }
  }
```

### dynamic block timeouts

Based on the values defined in timeouts,add allways the following structure for dynamic block timeouts:

```hcl
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.create, null)
      update = try(timeouts.update, null)
      read   = try(timeouts.read, null)
      delete = try(timeouts.delete, null)
    }
  }
```

or

```hcl
  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]

    content {
      create = try(timeouts.create, null)
      update = try(timeouts.update, null)
      delete = try(timeouts.delete, null)
    }
  }
```

Change null for default values if default values are provided.

### Arguments

#### Identify the changes needed in resources and variables for the existing module

Determine what needs to be added, modified, or removed in the module.

For that review [https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nameofresource , for example, if resource is `azurerm_container_app`, review https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nameofresource).

If a version of the provider is not specified, use the latest version available in the provider documentation.

If a version of the provider is specified, use `https://registry.terraform.io/providers/hashicorp/azurerm/version/docs/resources/nameofresource` , for example, if resource is `azurerm_container_app` and version is 4.32.0, review [https://registry.terraform.io/providers/hashicorp/azurerm/4.32.0/docs/resources/container_app](https://registry.terraform.io/providers/hashicorp/azurerm/version/docs/resources/nameofresource).

#### Default values

For arguments that do not have a default value, use the following structure:

```hcl
argument_name = try(var.argument_name, null)
```

For arguments that have default values, use the following structure, adjust default_value:

```hcl
argument_name = try(var.argument_name, default_value)
```

##### Conditional Arguments

For arguments that are conditional, use the following structure:

```hcl
argument_name = var.condition ? var.argument_name : null
```

##### Tags

For tags, use the following structure:

```hcl
tags                = merge(local.tags, try(var.settings.tags, null))
```

##### Resource Group

For resource groups, use the following structure:

```hcl
resource_group_name = local.resource_group.name
```

##### Location

For location, use the following structure:

```hcl
location            = local.location
```

##### argument service_plan_id

Use the following structure for argument service_plan_id:

```hcl

service_plan_id = coalesce(
    try(var.settings.service_plan_id, null),
    try(var.remote_objects.service_plans[try(var.settings.service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.service_plan.key, var.settings.service_plan_key)].id, null),
    try(var.remote_objects.app_service_plans[try(var.settings.app_service_plan.lz_key, var.client_config.landingzone_key)][try(var.settings.app_service_plan.key, var.settings.app_service_plan_key)].id, null)
  )
```

##### Other Instructions

- Search in workspace for the existing argument definitions and use them as a reference, if available.

## Updating Existing Modules

When updating existing modules, follow these steps:

### Module Modernization Process

1. **Review the existing module structure**: Understand how the current module is organized, including its variables, outputs, and resources.

2. **Identify the changes needed in resources and variables for the existing module**: Determine what needs to be added, modified, or removed in the module. For that review https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nameofresource, for example, if resource is `azurerm_container_app`, review https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app.

3. **Update the module files**: Make the necessary changes in the related files, such as `main.tf`, `variables.tf`, `outputs.tf`, and any other relevant files.

### Deprecated Resource Migration

When migrating from deprecated resources:

#### Pre-Migration Checklist

1. **Identify deprecated resources** in the current module
2. **Find the modern equivalent** using Azure provider documentation
3. **Assess breaking changes** between old and new resources
4. **Plan migration strategy** (in-place vs. new module)
5. **Update examples** to use modern resources

#### Migration Steps

1. **Update resource definitions** to use modern Azure resources
2. **Update variable schemas** to match new resource requirements
3. **Update outputs** to expose new resource attributes
4. **Add lifecycle management** if needed for complex dependencies
5. **Update documentation** and examples
6. **Test thoroughly** with example configurations

#### Post-Migration Validation

1. **Verify all arguments** are correctly mapped
2. **Test resource creation/update/deletion** cycles
3. **Validate outputs** are accessible and correct
4. **Check dependency resolution** works properly
5. **Ensure backward compatibility** where possible

### Testing and Validation

When updating modules, always test from the `/examples` directory:

```bash
# Navigate to examples directory
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples

# Test with specific module configuration
terraform_with_var_files --dir /category/module/example/  --action plan  --auto auto  --workspace example

# Full deployment test
terraform_with_var_files --dir /category/module/example/  --action apply  --auto auto  --workspace example

# Cleanup test
terraform_with_var_files --dir /category/module/example/  --action destroy  --auto auto  --workspace example
```

### Documentation Updates

When updating modules, ensure:

1. **Update module README.md** with new configuration examples
2. **Update example documentation** in `/examples/category/module/README.md`
3. **Document breaking changes** in appropriate changelog or migration guide
4. **Update variable descriptions** to reflect new functionality
5. **Add examples** for new features or patterns

### Quality Assurance

Before considering a module update complete:

1. **All examples must work** when tested from `/examples` directory
2. **No deprecated resources** should be used in new code
3. **Proper lifecycle management** must be implemented where needed
4. **Dependency resolution** must follow established patterns
5. **Integration with CAF framework** must be properly wired
6. **Documentation** must be updated and accurate
