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

Implement Azure Cloud Adoption Framework (CAF) naming conventions using a **hybrid naming system** that supports multiple naming methods for flexibility and migration scenarios. This approach provides three naming options: azurecaf provider, local naming module, and passthrough (manual names).

### Core Requirements

1. **Every module with named Azure resources MUST implement hybrid naming**
2. **Create `naming.tf` file in every module and submodule directory**
3. **Support three naming methods: azurecaf, local module, and passthrough**
4. **Integrate with global naming settings and maintain backward compatibility**
5. **Support configurable component order for advanced naming scenarios**

### Provider Configuration

Include both azurecaf and local naming module providers in ALL `providers.tf` files for modules with named resources:

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

### Global Settings Configuration

Extend `global_settings` in `locals.tf` to support hybrid naming:

```hcl
global_settings = merge({
  default_region     = try(var.global_settings.default_region, "region1")
  environment        = try(var.global_settings.environment, var.environment)
  inherit_tags       = try(var.global_settings.inherit_tags, false)
  prefix             = try(var.global_settings.prefix, null)
  suffix             = try(var.global_settings.suffix, null)
  # ... existing settings ...
  separator          = try(var.global_settings.separator, "-")
  passthrough        = try(var.global_settings.passthrough, false)
  use_slug           = try(var.global_settings.use_slug, true)
  clean_input        = try(var.global_settings.clean_input, true)

  # Hybrid naming configuration
  naming = merge({
    use_azurecaf      = try(var.global_settings.naming.use_azurecaf, true)
    use_local_module  = try(var.global_settings.naming.use_local_module, false)
    component_order   = try(var.global_settings.naming.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"])
  }, try(var.global_settings.naming, {}))
}, var.global_settings)
```

### Universal naming.tf Pattern

Create `naming.tf` file in EVERY module and submodule that creates named Azure resources:

```hcl
# Hybrid naming system for [resource_type]
# Supports three naming methods: passthrough, azurecaf, and local module

locals {
  # Determine naming method based on global settings priority:
  # 1. Passthrough (exact names)
  # 2. Local module (configurable CAF naming)
  # 3. Azurecaf (provider-based CAF naming)
  # 4. Fallback (original name)
  use_passthrough   = var.global_settings.passthrough
  use_local_module  = !local.use_passthrough && try(var.global_settings.naming.use_local_module, false)
  use_azurecaf      = !local.use_passthrough && !local.use_local_module && try(var.global_settings.naming.use_azurecaf, true)

  # Base name from settings
  base_name = var.settings.name
}

# Local naming module (conditional)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = "azurerm_[resource_type]"
  name            = local.base_name
  environment     = try(var.settings.environment, var.global_settings.environment, "")
  region          = try(var.settings.region, try(var.global_settings.regions[var.global_settings.default_region], ""), "")
  instance        = try(var.settings.instance, "")
  prefix          = try(var.settings.prefix, try(var.global_settings.prefix, ""))
  suffix          = try(var.settings.suffix, try(var.global_settings.suffix, ""))
  separator       = var.global_settings.separator
  component_order = try(var.global_settings.naming.component_order, ["prefix", "abbreviation", "name", "environment", "region", "instance", "suffix"])
  clean_input     = var.global_settings.clean_input
  validate        = true
}

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "main_resource" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_[resource_type]"  # Use closest supported type if exact type not available
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}

# Final name resolution with priority
locals {
  final_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? module.local_naming[0].result : (
      local.use_azurecaf ? azurecaf_name.main_resource[0].result : local.base_name
    )
  )

  # Naming method for debugging/monitoring
  naming_method = local.use_passthrough ? "passthrough" : (
    local.use_local_module ? "local_module" : (
      local.use_azurecaf ? "azurecaf" : "fallback"
    )
  )
}
```

### Resource Implementation

Update ALL resource definitions to use the hybrid naming system:

```hcl
# ❌ INCORRECT - Direct name usage
resource "azurerm_[resource_type]" "resource_name" {
  name = var.settings.name
  # ... other attributes
}

# ❌ INCORRECT - Direct azurecaf usage
resource "azurerm_[resource_type]" "resource_name" {
  name = azurecaf_name.main_resource.result
  # ... other attributes
}

# ✅ CORRECT - Hybrid naming system
resource "azurerm_[resource_type]" "resource_name" {
  name = local.final_name
  # ... other attributes
}
```

### Universal Outputs Pattern

Add naming outputs to ALL modules with named resources:

```hcl
# ALWAYS include the final name output
output "name" {
  value       = local.final_name
  description = "The name of the [resource_type]"
}

# ALWAYS include the naming method output
output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

# Standard resource outputs
output "id" {
  value = azurerm_[resource_type].resource_name.id
}

# ... other specific outputs for the resource type
```

### Resource Type Mapping

Map each Azure resource to its corresponding azurecaf resource type. Common mappings:

| Azure Resource                 | azurecaf Resource Type           |
| ------------------------------ | -------------------------------- |
| azurerm_resource_group         | `azurerm_resource_group`         |
| azurerm_storage_account        | `azurerm_storage_account`        |
| azurerm_storage_container      | `azurerm_storage_container`      |
| azurerm_key_vault              | `azurerm_key_vault`              |
| azurerm_virtual_network        | `azurerm_virtual_network`        |
| azurerm_subnet                 | `azurerm_subnet`                 |
| azurerm_network_security_group | `azurerm_network_security_group` |
| azurerm_public_ip              | `azurerm_public_ip`              |
| azurerm_application_gateway    | `azurerm_application_gateway`    |
| azurerm_kubernetes_cluster     | `azurerm_kubernetes_cluster`     |
| azurerm_container_registry     | `azurerm_container_registry`     |
| azurerm_app_service_plan       | `azurerm_app_service_plan`       |
| azurerm_linux_web_app          | `azurerm_linux_web_app`          |
| azurerm_windows_web_app        | `azurerm_windows_web_app`        |
| azurerm_function_app           | `azurerm_function_app`           |
| azurerm_mssql_server           | `azurerm_mssql_server`           |
| azurerm_mssql_database         | `azurerm_mssql_database`         |
| azurerm_cosmosdb_account       | `azurerm_cosmosdb_account`       |
| azurerm_cdn_profile            | `azurerm_cdn_profile`            |
| azurerm_cdn_frontdoor_profile  | `azurerm_cdn_frontdoor_profile`  |
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

Update ALL examples to include both azurecaf and local naming module providers:

```hcl
# examples/main.tf - ALWAYS include both providers
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

### Examples Directory Structure

Follow the established pattern for organizing examples by complexity:

```
examples/
├── naming/                    # Naming-specific examples
│   ├── 101-azurecaf-naming/          # Basic azurecaf usage
│   ├── 102-passthrough-naming/       # Basic passthrough usage
│   ├── 201-local-module-naming/      # Intermediate local module usage
│   ├── 202-local-module-validation/  # Intermediate with validation
│   └── 301-custom-component-order/   # Advanced component order
├── cognitive_services/
│   └── 100-ai-services/              # Basic AI services example
├── networking/
│   ├── 100-virtual-network/          # Basic networking
│   └── 200-complex-network/          # Complex networking
└── README.md
```

### Example Numbering Convention

- **100-199**: Basic examples (simple configurations)
- **200-299**: Intermediate examples (moderate complexity)
- **300-399**: Advanced examples (complex scenarios)
- **400-499**: Comparison/migration examples

### Example Configuration Structure

Each example should include:

```
101-example-name/
├── configuration.tfvars       # Main configuration
├── terraform.tfvars          # Optional additional variables
└── README.md                 # Example documentation
```

### Benefits for ALL Modules

1. **Consistency**: Standardized naming across ALL Azure resources in CAF
2. **Compliance**: Automatic adherence to Azure naming conventions
3. **Validation**: Built-in validation of name length and character restrictions
4. **Flexibility**: Configurable prefixes, suffixes, and separators per environment
5. **Cleanliness**: Automatic removal of invalid characters
6. **Identification**: Clear resource type identification through naming slugs
7. **Scalability**: Works across all Azure resource types and landing zones
8. **Migration Path**: Smooth transition from azurecaf to local module or vice versa

### Implementation Priority

1. **New Modules**: MUST implement hybrid naming from creation
2. **Existing Critical Modules**: Update high-usage modules first
3. **Legacy Modules**: Gradual migration with backward compatibility
4. **Examples**: Update to support all naming methods in example configurations

### Reference Implementations

- `modules/cognitive_services/ai_services/` - Complete example with hybrid naming
- `modules/cdn/cdn_frontdoor_profile/` - Multi-resource module pattern
- `examples/naming/` - Comprehensive naming examples

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

When migrating from deprecated resources to their modern equivalents:

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

### Debugging Test Failures

When debugging test failures, follow these systematic troubleshooting steps:

#### Primary Debugging Strategy

1. **First step: Review equivalent examples within `/examples`**
   - Search for similar modules or configurations in the examples directory
   - Compare the tfvars structure and content with working examples
   - Look for patterns in how other modules are configured
   - Pay attention to naming conventions and object structures

2. **Verify tfvars alignment with module expectations**
   - The tfvars files must be adjusted to match the module's expected structure
   - **Rule: tfvars should adapt to the module, not the other way around**
   - Review module variables and expected input structure
   - Check for mismatched attribute names or incorrect object nesting

#### Common tfvars Issues

1. **Incorrect object structure**: Module expects flat attributes but tfvars provides nested objects (or vice versa)
2. **Wrong attribute names**: Using deprecated or incorrect property names
3. **Missing required blocks**: Not providing mandatory configuration blocks
4. **Mixing configuration patterns**: Combining basic infrastructure config with application-specific config

#### Debugging Process

1. **Compare with working examples**:

   ```bash
   # Find similar examples
   find /examples -name "*.tfvars" -path "*similar_service*" | head -5
   ```

2. **Validate module expectations**:
   - Read module's `variables.tf` to understand expected structure
   - Review module's resource definitions to see how variables are used
   - Check for any transformation logic in `locals.tf`

3. **Test incrementally**:
   - Start with minimal configuration from working examples
   - Add complexity gradually
   - Test each addition to isolate issues

#### Configuration Philosophy

- **Modules are the source of truth**: Module design and structure should not be changed to accommodate incorrect tfvars
- **Examples provide patterns**: Use existing examples as templates for similar use cases
- **Consistency is key**: Follow established patterns across the CAF framework
- **Separation of concerns**: Distinguish between infrastructure configuration and application configuration

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

### Debugging Test Failures

When debugging test failures, follow these systematic troubleshooting steps:

#### Primary Debugging Strategy

1. **First step: Review equivalent examples within `/examples`**
   - Search for similar modules or configurations in the examples directory
   - Compare the tfvars structure and content with working examples
   - Look for patterns in how other modules are configured
   - Pay attention to naming conventions and object structures

2. **Verify tfvars alignment with module expectations**
   - The tfvars files must be adjusted to match the module's expected structure
   - **Rule: tfvars should adapt to the module, not the other way around**
   - Review module variables and expected input structure
   - Check for mismatched attribute names or incorrect object nesting

#### Common tfvars Issues

1. **Incorrect object structure**: Module expects flat attributes but tfvars provides nested objects (or vice versa)
2. **Wrong attribute names**: Using deprecated or incorrect property names
3. **Missing required blocks**: Not providing mandatory configuration blocks
4. **Mixing configuration patterns**: Combining basic infrastructure config with application-specific config

#### Debugging Process

1. **Compare with working examples**:

   ```bash
   # Find similar examples
   find /examples -name "*.tfvars" -path "*similar_service*" | head -5
   ```

2. **Validate module expectations**:
   - Read module's `variables.tf` to understand expected structure
   - Review module's resource definitions to see how variables are used
   - Check for any transformation logic in `locals.tf`

3. **Test incrementally**:
   - Start with minimal configuration from working examples
   - Add complexity gradually
   - Test each addition to isolate issues

#### Configuration Philosophy

- **Modules are the source of truth**: Module design and structure should not be changed to accommodate incorrect tfvars
- **Examples provide patterns**: Use existing examples as templates for similar use cases
- **Consistency is key**: Follow established patterns across the CAF framework
- **Separation of concerns**: Distinguish between infrastructure configuration and application configuration

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

### Debugging Test Failures

When debugging test failures, follow these systematic troubleshooting steps:

#### Primary Debugging Strategy

1. **First step: Review equivalent examples within `/examples`**
   - Search for similar modules or configurations in the examples directory
   - Compare the tfvars structure and content with working examples
   - Look for patterns in how other modules are configured
   - Pay attention to naming conventions and object structures

2. **Verify tfvars alignment with module expectations**
   - The tfvars files must be adjusted to match the module's expected structure
   - **Rule: tfvars should adapt to the module, not the other way around**
   - Review module variables and expected input structure
   - Check for mismatched attribute names or incorrect object nesting

#### Common tfvars Issues

1. **Incorrect object structure**: Module expects flat attributes but tfvars provides nested objects (or vice versa)
2. **Wrong attribute names**: Using deprecated or incorrect property names
3. **Missing required blocks**: Not providing mandatory configuration blocks
4. **Mixing configuration patterns**: Combining basic infrastructure config with application-specific config

#### Debugging Process

1. **Compare with working examples**:

   ```bash
   # Find similar examples
   find /examples -name "*.tfvars" -path "*similar_service*" | head -5
   ```

2. **Validate module expectations**:
   - Read module's `variables.tf` to understand expected structure
   - Review module's resource definitions to see how variables are used
   - Check for any transformation logic in `locals.tf`

3. **Test incrementally**:
   - Start with minimal configuration from working examples
   - Add complexity gradually
   - Test each addition to isolate issues

#### Configuration Philosophy

- **Modules are the source of truth**: Module design and structure should not be changed to accommodate incorrect tfvars
- **Examples provide patterns**: Use existing examples as templates for similar use cases
- **Consistency is key**: Follow established patterns across the CAF framework
- **Separation of concerns**: Distinguish between infrastructure configuration and application configuration

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

### Debugging Test Failures

When debugging test failures, follow these systematic troubleshooting steps:

#### Primary Debugging Strategy

1. **First step: Review equivalent examples within `/examples`**
   - Search for similar modules or configurations in the examples directory
   - Compare the tfvars structure and content with working examples
   - Look for patterns in how other modules are configured
   - Pay attention to naming conventions and object structures

2. **Verify tfvars alignment with module expectations**
   - The tfvars files must be adjusted to match the module's expected structure
   - **Rule: tfvars should adapt to the module, not the other way around**
   - Review module variables and expected input structure
   - Check for mismatched attribute names or incorrect object nesting

#### Common tfvars Issues

1. **Incorrect object structure**: Module expects flat attributes but tfvars provides nested objects (or vice versa)
2. **Wrong attribute names**: Using deprecated or incorrect property names
3. **Missing required blocks**: Not providing mandatory configuration blocks
4. **Mixing configuration patterns**: Combining basic infrastructure config with application-specific config

#### Debugging Process

1. **Compare with working examples**:

   ```bash
   # Find similar examples
   find /examples -name "*.tfvars" -path "*similar_service*" | head -5
   ```

2. **Validate module expectations**:
   - Read module's `variables.tf` to understand expected structure
   - Review module's resource definitions to see how variables are used
   - Check for any transformation logic in `locals.tf`

3. **Test incrementally**:
   - Start with minimal configuration from working examples
   - Add complexity gradually
   - Test each addition to isolate issues

#### Configuration Philosophy

- **Modules are the source of truth**: Module design and structure should not be changed to accommodate incorrect tfvars
- **Examples provide patterns**: Use existing examples as templates for similar use cases
- **Consistency is key**: Follow established patterns across the CAF framework
- **Separation of concerns**: Distinguish between infrastructure configuration and application configuration

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
    value = block.value.value  }
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

## Hybrid Naming System Testing

### Testing Different Naming Methods

The hybrid naming system supports three methods that can be tested systematically:

#### 1. Azurecaf Naming (Default/Legacy)

```bash
# Test basic azurecaf naming
terraform_with_var_files --dir ./naming/101-azurecaf-naming/ --action plan --auto auto --workspace test

# Test azurecaf with random suffix
terraform_with_var_files --dir ./naming/103-azurecaf-with-random/ --action plan --auto auto --workspace test
```

#### 2. Passthrough Naming (Manual)

```bash
# Test exact name passthrough
terraform_with_var_files --dir ./naming/102-passthrough-naming/ --action plan --auto auto --workspace test
```

#### 3. Local Module Naming (Advanced)

```bash
# Test local module basic
terraform_with_var_files --dir ./naming/201-local-module-naming/ --action plan --auto auto --workspace test

# Test local module with validation
terraform_with_var_files --dir ./naming/202-local-module-validation/ --action plan --auto auto --workspace test

# Test custom component order
terraform_with_var_files --dir ./naming/301-custom-component-order/ --action plan --auto auto --workspace test

# Test environment-specific naming
terraform_with_var_files --dir ./naming/302-environment-specific-naming/ --action plan --auto auto --workspace test
```

### Common Naming Issues and Solutions

#### Issue: azurecaf resource type not supported

**Problem**: `azurerm_ai_services` is not supported by azurecaf provider
**Solution**: Use closest supported type (e.g., `azurerm_cognitive_account`)

```hcl
# In naming.tf
resource "azurecaf_name" "main_resource" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_cognitive_account"  # Fallback for unsupported types
  # ... other settings
}
```

#### Issue: Variable not declared

**Problem**: Using `cognitive_services` instead of `ai_services`
**Solution**: Use correct variable name as defined in module

```hcl
# ❌ INCORRECT
cognitive_services = {
  ai_services = { ... }
}

# ✅ CORRECT
ai_services = {
  example = { ... }
}
```

#### Issue: Dependency lock file conflicts

**Problem**: Provider version conflicts
**Solution**: Run `terraform init -upgrade` to update lock file

```bash
cd /home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/examples
terraform init -upgrade
```

### Best Practices for Naming Implementation

1. **Always implement hybrid naming** for new modules
2. **Use resource type mapping** for azurecaf compatibility
3. **Test all three naming methods** before finalizing
4. **Document naming behavior** in module README
5. **Provide example configurations** for each naming method
6. **Use appropriate resource constraints** in local naming module
7. **Handle unsupported resource types** gracefully with fallbacks
