resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_info.name
  location            = var.resource_group_info.location
  resource_group_name = var.resource_group_info.name
  dns_prefix          = var.cluster_info.dns_prefix

  azure_policy_enabled = try(var.cluster_info.opt.azure_policy_enabled, false)

  //Encryption
  disk_encryption_set_id = try(var.cluster_info.opt.disk_encryption_set_id, null)

  //Edge Zone
  edge_zone = try(var.cluster_info.opt.edge_zone, 3)
  
  default_node_pool {
    name       = var.cluster_info.default_node_pool.name
    node_count = var.cluster_info.default_node_pool.count
    vm_size    = try(var.cluster_info.default_node_pool.size, "Standard_D2_v2")
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
