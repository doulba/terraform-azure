variable "resource_group_info" {
  description = "(Required) Specifies the resource group info"
  default = {
    name     = ""
    location = ""
  }
}

variable "vm_info" {
  description = "(Required) Specifies the some ifno of the virtual machine"
  default = {
    name              = ""
    computer_name     = ""
    size              = ""
    public_ip         = false
    allocation_method = "Dynamic"
    domain_name_label = ""
  }
}

variable "os_disk_info" {
  description = "todo"
  default = {
    name    = "todo"
    size    = 30
    caching = "ReadWrite"
    image = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "20.04-LTS"
      version   = "latest"
    }
    storage_account_type                  = "Premium_LRS"
    boot_diagnostics_storage_account_name = ""
  }
  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.os_disk_info.storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "data_disk_info" {
  description = "todo"
  default = {
    enabled = false
    name                 = "todo"
    size                 = 30
    caching              = "ReadWrite"
    create_option        = ""
    lun                  = 1
    storage_account_type = "Premium_LRS"
  }
  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.data_disk_info.storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "network_info" {
  description = "todo"
  default = {
    subnet_id         = ""
    security_group_id = ""
  }
}

variable "admin_info" {
  description = ""
  default = {
    identities       = []
    disable_password = false
    username         = "azadmin"
    password         = ""
    public_key       = ""
  }
}


variable "log_analytics_info" {
  description = "todo"
  default = {
    workspace_id   = ""
    workspace_key  = ""
    retention_days = 0
  }
}

variable "disk_encryption_set_id" {
  description = "(Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk"
  default     = null
}

variable "cloud_init_info" {
  description = "todo"
  default = {
    script  = "scripts/vm-admin-config.yaml"
    enabled = false
    vars    = {}
  }
}

variable "extension_info" {
  description = "todo"
  default = {
    monitor_agent = {
      enabled = false
      version = "1.12"
    }
    dependency_agent = {
      enabled = false
      version = "9.10"
    }
  }

}

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
}
