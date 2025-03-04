# Instructions for Creating a Terraform Module

## Directory Structure

/ is the root directory of the repository.Create the following directory structure for the Terraform module:


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
                    │   ├── resource1.tf
                    │   ├── main.tf
                    │   ├── output.tf
                    │   ├── providers.tf
                    │   └── variables.tf
                    ├── resource2
                    │   ├── resource2.tf
                    │   ├── main.tf
                    │   ├── output.tf
                    │   ├── providers.tf
                    │   └── variables.tf
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




## Modify existing files

### /local.remote_objects.tf

Insert alphabetically the following code to the file inside of locals { }:

module_names = try(local.combined_objects_module_names, null)

Example with module_nameequal to resource_groups:

```hcl
network_managers                               = try(local.combined_objects_network_managers, null)
```

### /locals.combined_objects.tf

Insert alphabetically the following code to the file inside of locals { }:

combined_objects_module_names = merge(tomap({ (local.client_config.landingzone_key) = module.module_names }), lookup(var.remote_objects, "module_names", {}), lookup(var.data_sources, "module_names", {}))

Example with module_name equal to resource_groups:

```hcl
combined_objects_network_managers                               = merge(tomap({ (local.client_config.landingzone_key) = module.network_managers }), lookup(var.remote_objects, "network_managers", {}), lookup(var.data_sources, "network_managers", {}))
```

### /locals.tf

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

### /category_name_module_names.tf

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

### /modules/category_name/module_name/module_name.tf

Add the following code to the file:

```hcl
resource "azurerm_module_name" "module_name" {
  name                = var.settings.name
  location            = local.location
  resource_group_name = local.resource_group_name
  # Other arguments
  
}
```

### /modules/category_name/module_name/locals.tf

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

### /modules/category_name/module_name/outputs.tf

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





### /modules/category_name/module_name/providers.tf

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

### /modules/category_name/module_name/variables.tf

Add the following code to the file:

```hcl
variable "global_settings" {
  description = <<DESCRIPTION
  Global settings object
  DESCRIPTION
  type        = any
}
variable "client_config" {
  description = <<DESCRIPTION
  Client configuration object
  DESCRIPTION
  type        = any
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

### /modules/category_name/module_name/diagnostics.tf

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

### /modules/category_name/module_name/main.tf

Add the following code to the file:

```hcl
#This file is maintained by legacy purposes. Please do not modify this file.
```	

### /modules/category_name/module_name/managed_identitties.tf

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

### /examples/module.tf

Add the following code to the file inside of locals { }:

category_name = {
module_names = var.module_names
}

Example with module_name equal to service_plans  and category_name equal to webapp:

```hcl
webapp = {    
    service_plans                                  = var.service_plans    
  }
```

## Coding Instructions

### Necessary Blocks

Use the following structure for necessary blocks:

```hcl
block_name {
    argument_name = var.settings.argument_name
}
```

### Dynamic Blocks

#### Optional Single Destination Block

Use the following structure for optional single destination blocks:

```hcl
dynamic "block" {
    for_each = try(var.settings.block, null) == null ? [] : [var.settings.block]
    content {
        name = block.value.name
        value = block.value.value
    }
}
```
#### Optional Multiple Destination Blocks

Use the following structure for optional multiple destination blocks:

```hcl
dynamic "block" {
    for_each = try(var.settings.block, null) == null ? [] : var.settings.block
    content {
        name = block.value.name
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
      identity_ids = contains(["userassigned", "systemassigned", "systemassigned, userassigned"], lower(var.identity.type)) ? local.managed_identities : null
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

#### Default values

For arguments that without default value, use the following structure:

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

##### Other Instructions

- Search in workspace for the existing argument definitions and use them as a reference, if available.


### Commit messages

Use Conventional Commits for commit messages:

```plaintext
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

Examples:

- `feat(network): add network group`
- `fix(security): fix security issue`
- `chore(trunk): update trunk`
- `docs(readme): update readme`
