#
# Extensions
#

resource "azurerm_kubernetes_cluster_extension" "extensions" {
  for_each = try(var.settings.extensions, {})

  name                             = each.value.name
  cluster_id                       = azurerm_kubernetes_cluster.aks.id
  extension_type                   = each.value.extension_type
  configuration_protected_settings = try(each.value.configuration_protected_settings, null)
  configuration_settings           = try(each.value.configuration_settings, null)
  dynamic "plan" {
    for_each = try(each.value.plan, null) == null ? [] : [1]
    content {
      name           = plan.value.name
      product        = plan.value.product
      publisher      = plan.value.publisher
      promotion_code = try(plan.value.promotion_code, null)
      version        = try(plan.value.version, null)
    }

  }
  release_train     = try(each.value.release_train, null)
  release_namespace = try(each.value.release_namespace, null)
  target_namespace  = try(each.value.target_namespace, null)

}