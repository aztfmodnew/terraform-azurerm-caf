
Use Conventional Commits.

For dynamics blocks, (Optional) One  destination blockst,use something like this:
dynamic "block" {
    for_each = try(var.settings.block, null) == null ? [] : [var.settings.block]
    content {
        name = block.value.name
        value = block.value.value
    }
}


For dynamics blocks, (Optional) One or more destination blocks, use something like this:
dynamic "block" {
    for_each = try(var.settings.block, null) == null ? [] : var.settings.block
    content {
        name = block.value.name
        value = block.value.value
    }
}


For arguments that are not required, use something like this: argument = try(var.settings.argument, null).

If argument have an default value, use something like this: argument = try(var.settings.argument, default_value).





