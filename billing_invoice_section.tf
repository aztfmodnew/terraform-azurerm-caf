module "invoice_section" {
  source   = "./modules/billing/invoice_sections"
  for_each = try(var.invoice_sections, {})

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  base_tags       = local.global_settings.inherit_tags
  resource_group  = try(each.value.resource_group, null)
}

output "invoice_sections" {
  value = module.invoice_section
}
