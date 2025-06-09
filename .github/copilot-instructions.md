# Instructions for Creating a Terraform Module

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

## Instructions for Working with the `/examples` Directory

The `/examples` directory provides a framework to demonstrate and test the modules in this repository using various configurations loaded from `.tfvars` files.

### Root Example Configuration Files (within `/examples/`)

- **`main.tf`**: Contains the primary example configuration, including provider setup. It's designed to be generic enough to work with different `.tfvars` files.
- **`variables.tf`**: Defines all possible input variables that might be used by any module being demonstrated. The actual values will come from the `.tfvars` files.
- **`outputs.tf`**: Defines outputs for the examples.
- **`module.tf`**: This crucial file instantiates the various modules from the repository. It should be written to accept configurations for these modules from the variables defined in `variables.tf` (which are populated by `.tfvars` files).

  - **Pattern for `module.tf` `locals`:**
    When referencing module configurations within `locals` in `/examples/module.tf`, use the following pattern:
    ```hcl
    locals {
      category_name = {
        module_name_plural = var.module_name_plural // Corresponds to a variable in /examples/variables.tf
      }
    }
    ```
    _Replace `category_name` with the actual category (e.g., `networking`)._
    _Replace `module_name_plural` with the pluralized name of the module as defined in `/examples/variables.tf` (e.g., `virtual_networks`)._

- **`variables.provider.tf`**: Contains provider-specific variable definitions.
- **`backend.azurerm`**: Configures the Azure Blob Storage backend for Terraform state for the examples.

### Example `.tfvars` File Structure and Naming

Input variable files (`.tfvars`) are organized hierarchically. Within each specific example directory (`<level-nameoftheexample>`), the `.tfvars` files should be named as follows:

- **Option 1 (Single Configuration File):**
  Use a single file named `configuration.tfvars` if the example primarily configures one main resource or a tightly coupled set of resources.
  _Path: `examples/<category_name>/<module_name>/<level-nameoftheexample>/configuration.tfvars`_

- **Option 2 (Multiple Resource-Specific Files):**
  If the example demonstrates the creation of several distinct types of resources that can be configured somewhat independently, create a separate `.tfvars` file for each major resource type.
  _Paths:
  `examples/<category_name>/<module_name>/<level-nameoftheexample>/<resource_type1_config>.tfvars`
  `examples/<category_name>/<module_name>/<level-nameoftheexample>/<resource_type2_config>.tfvars`
  (e.g., `virtual_network.tfvars`, `storage_account.tfvars`)_

**Directory Structure Overview:**

- **`<category_name>`**: A directory representing the module category (e.g., `networking`, `compute`, `storage`).
- **`<module_name>`**: A directory representing the specific module being demonstrated (e.g., `virtual_network`, `container_app`, `storage_account`). This should match the `module_name` used in the module's own directory structure (e.g., `/modules/category_name/module_name/`).
- **`<level-nameoftheexample>`**: A directory whose name starts with the level (`100-`, `200-`, `300-`) followed by a descriptive name for the type or complexity of the example (e.g., `100-basic-default`, `200-hub-spoke-config`, `300-advanced-security-rules`).

### Adding a New Example (Directory and `.tfvars` file)

When adding examples for a new module `module_name` under `category_name`:

1.  **Create Module Example Directory:**
    Create the directory `examples/<category_name>/<module_name>/`.

2.  **Create `README.md` in Module Example Directory:**
    Inside `examples/<category_name>/<module_name>/`, create a `README.md` file. This file should:

    - Explain the purpose of the examples for this module.
    - Describe the different levels (`100-xxx`, `200-xxx`, etc.) and what they represent.
    - Provide instructions on how to run these examples, including the `terraform apply -var-file=...` command structure, covering both single and multiple `.tfvars` file scenarios.
    - List any prerequisites or special considerations.

3.  **Create `main.tf` in Module Example Directory:**
    Inside `examples/<category_name>/<module_name>/`, create a `main.tf` file with the following content:

    ```hcl
    # trunk-ignore-all(tflint/terraform_required_version)
    # This is an empty file for Terraform registry visibility.
    # For examples on how to consume the CAF module, please refer to https://github.com/aztfmodnew/terraform-azurerm-caf/tree/master/examples
    ```

4.  **Create Specific Example Level Directory:**
    Inside `examples/<category_name>/<module_name>/`, create a directory for the specific example type, following the `level-nameoftheexample` pattern.
    Example: `examples/networking/virtual_network/100-basic-default/`

5.  **Create and Populate `.tfvars` File(s):**
    Inside the newly created `<level-nameoftheexample>` directory:

    - If using a single configuration file, create `configuration.tfvars`.
    - If using multiple resource-specific files, create them accordingly (e.g., `virtual_networks.tfvars`, `subnets.tfvars`).

    Populate these file(s) with the necessary variables and their values to configure the module(s) for this specific scenario. These variables must correspond to those defined in the root `/examples/variables.tf`.

    Example (`examples/networking/virtual_network/100-basic-default/configuration.tfvars`):

    ```hcl
    # examples/networking/virtual_network/100-basic-default/configuration.tfvars

    virtual_networks = {
      default_vnet_key = {
        name            = "my-basic-vnet"
        address_space   = ["10.2.0.0/16"]
        # ... other necessary attributes
      }
    }

    resource_groups = {
      default_rg_key = {
        name     = "my-basic-rg"
        location = "westeurope"
      }
    }
    ```

6.  **Ensure Root `module.tf` and `variables.tf` Support:**
    - Verify that the root `/examples/module.tf` is set up to instantiate the target module(s) using the variable structure you're defining in the `.tfvars` file(s).
    - Verify that all top-level variables used in your `.tfvars` files are declared in the root `/examples/variables.tf`.

### Running an Example

To run a specific example:

1.  Navigate to the `/examples` root directory in your terminal.
2.  Initialize Terraform: `terraform init`
3.  Plan or apply using the desired `.tfvars` file(s):

    - **Single `configuration.tfvars` file:**

      ```bash
      terraform plan -var-file=./<category_name>/<module_name>/<level-nameoftheexample>/configuration.tfvars
      terraform apply -var-file=./<category_name>/<module_name>/<level-nameoftheexample>/configuration.tfvars
      ```

      Example:

      ```bash
      terraform apply -var-file=./networking/virtual_network/100-basic-default/configuration.tfvars
      ```

    - **Multiple resource-specific `.tfvars` files:**

      ```bash
      terraform plan \
        -var-file=./<category_name>/<module_name>/<level-nameoftheexample>/<resource_type1_config>.tfvars \
        -var-file=./<category_name>/<module_name>/<level-nameoftheexample>/<resource_type2_config>.tfvars

      terraform apply \
        -var-file=./<category_name>/<module_name>/<level-nameoftheexample>/<resource_type1_config>.tfvars \
        -var-file=./<category_name>/<module_name>/<level-nameoftheexample>/<resource_type2_config>.tfvars
      ```

      Example:

      ```bash
      terraform apply \
        -var-file=./networking/complex_setup_module/200-multi-resource/virtual_networks.tfvars \
        -var-file=./networking/complex_setup_module/200-multi-resource/storage_accounts.tfvars
      ```

### Documentation

- Update the root `/examples/README.md` to include information about new module example structures or significant scenarios if necessary.
- The primary documentation for a module's examples should reside in `examples/<category_name>/<module_name>/README.md`.
- Ensure that the documentation is clear, concise, and provides enough context for users to understand how to use the examples effectively.

## Code Style

### Necessary Blocks

Use the following structure for necessary blocks:

```hcl
block_name {
    argument_name = var.settings.argument_name
}
```

Of course! Here is the English translation of the provided guide.

---

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

1.  **Review the existing module structure**: Understand how the current module is organized, including its variables, outputs, and resources.
2.  **Identify the changes needed in resources and variables for the existing module**: Determine what needs to be added, modified, or removed in the module. For that review https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nameofresource , for example, if resource is `azurerm_container_app`, review https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app.
3.  **Update the module files**: Make the necessary changes in the related files, such as `main.tf`, `variables.tf`, `outputs.tf`, and any other relevant files.
