variable "cluster_info" {
  description = "AKS Cluster info"
  default = {
    name = "aks-devops-poc-frcen-1"
    dns_prefix = "devopspoc-frcen"
    default_node_pool = {
        name = "default"
        count = 1
        size = "Standard_D2_v2"
    }
  }
}

variable "resource_group_info" {
  description = "Resource group hosting the AKS Cluster"
  default = {
    name = "rgp-devops-poc-frcen"
    location = "francecentral"
  }
}
