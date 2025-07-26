output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  value = azurecaf_name.aks.result
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "aks_kubeconfig_cmd" {
  value = format("az aks get-credentials --name %s --resource-group %s --overwrite-existing", azurecaf_name.aks.result, local.resource_group_name)
}

output "aks_kubeconfig_admin_cmd" {
  value = format("az aks get-credentials --name %s --resource-group %s --overwrite-existing --admin", azurecaf_name.aks.result, local.resource_group_name)
}

output "kubelet_identity" {
  description = "User-defined Managed Identity assigned to the Kubelets"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity
}

output "identity" {
  description = "System assigned identity which is used by master components"
  value       = azurerm_kubernetes_cluster.aks.identity
}

output "enable_rbac" {
  value = lookup(var.settings, "enable_rbac", true)
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config
}

output "rbac_id" {
  value = length(azurerm_kubernetes_cluster.aks.kubelet_identity) > 0 ? azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id : ""
}


output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "private_fqdn" {
  value = azurerm_kubernetes_cluster.aks.private_fqdn
}

# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
