# Copilot Instructions for Creating a Terraform Module

## Directory Structure
/ is the root directory of the repository.Create the following directory structure for the Terraform module:

```plaintext
/modules
└── /category_name/
                └── module_name
                ├── main.tf
                ├── outputs.tf
                ├── providers.tf
                ├── variables.tf
                ├── diagnostics.tf
                ├── locals.tf
                ├── module.tf
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
/module_name.tf
```
## Modify existing files
### /local.remote_objects.tf

Add the following code to the file:

combined_objects_module_name                               = try(local.combined_objects_module_name, null)

Example with module_nameequal to resource_groups:

```hcl
combined_objects_resource_groups                                = try(local.combined_objects_resource_groups, null)
```

### /locals.combined_objects.tf

Add the following code to the file:

combined_objects_module_name               = merge(tomap({ (local.client_config.landingzone_key) = merge(local.module_name, lookup(var.data_sources, "module_name", {})) }), lookup(var.remote_objects, "module_name", {}))

Example with module_name equal to resource_groups:

```hcl
combined_objects_resource_groups                                = merge(tomap({ (local.client_config.landingzone_key) = merge(local.resource_groups, lookup(var.data_sources, "resource_groups", {})) }), lookup(var.remote_objects, "resource_groups", {}))
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

Example with category_name equal to cognitive_services and module_name    cognitive_services_account:

```hcl
locals {
  cognitive_services = {
    cognitive_services_account = try(var.cognitive_services.cognitive_services_account, {})
  }
}
```
### /module_name.tf

Add the following code to the file:

```hcl
module "module_name" {
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

output "module_name" {
  value = module.module_name
}
```

### /modules/category_name/module_name/azurerm_module_name.tf

Add the following code to the file:

```hcl
resource "azurerm_module_name" "module_name" {
  name                = var.settings.name
  location            = local.location
  resource_group_name = local.resource_group_name
  #arguments
  #dynamic blocks

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

### Optional Arguments

For arguments that are optional, use the following structure:

```hcl
argument_name = try(var.argument_name, null)
```

### Arguments with Default Values

For arguments that have default values, use the following structure:

```hcl
argument_name = try(var.argument_name, "default_value")
```

### Conditional Arguments

For arguments that are conditional, use the following structure:

```hcl
argument_name = var.condition ? var.argument_name : null
```

### Tags

For tags, use the following structure:

```hcl
tags                = merge(local.tags, try(var.settings.tags, null))
```

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