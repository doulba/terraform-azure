output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config
  sensitive = true
}

output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}
