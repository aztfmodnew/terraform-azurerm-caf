locals {
  developer_portal_blocks = merge(
    coalesce(try(var.settings.developer_portals, null), {}),
    try(var.settings.developer_portal, null) == null ? {} : { default = var.settings.developer_portal }
  )

  management_blocks = merge(
    coalesce(try(var.settings.managements, null), {}),
    try(var.settings.management, null) == null ? {} : { default = var.settings.management }
  )

  portal_blocks = merge(
    coalesce(try(var.settings.portals, null), {}),
    try(var.settings.portal, null) == null ? {} : { default = var.settings.portal }
  )

  gateway_blocks = merge(
    try({ for key, value in var.settings.proxy : tostring(key) => value }, {}),
    try(var.settings.proxy, null) == null ? try({ for key, value in var.settings.gateways : tostring(key) => value }, {}) : {},
    try(var.settings.gateway, null) == null ? {} : { default = var.settings.gateway }
  )

  scm_blocks = merge(
    coalesce(try(var.settings.scms, null), {}),
    try(var.settings.scm, null) == null ? {} : { default = var.settings.scm }
  )
}
