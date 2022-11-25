resource "azurerm_public_ip" "public_ip" {
  count = var.vm_info.public_ip ? 1 : 0

  name                = "pip-${var.vm_info.name}"
  location            = var.resource_group_info.location
  resource_group_name = var.resource_group_info.name
  allocation_method   = try(var.vm_info.allocation_method, "Dynamic")
  domain_name_label   = lower(var.vm_info.domain_name_label)
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.vm_info.name}"
  location            = var.resource_group_info.location
  resource_group_name = var.resource_group_info.name
  tags                = var.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.network_info.subnet_id
    private_ip_address_allocation = try(var.vm_info.allocation_method, "Dynamic")
    public_ip_address_id          = try(azurerm_public_ip.public_ip[0].id, "")
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.network_info.security_group_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_info.name
  location              = var.resource_group_info.location
  resource_group_name   = var.resource_group_info.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_info.size
  computer_name         = try(var.vm_info.computer_name, var.vm_info.name)
  admin_username        = var.admin_info.username
  admin_password        = var.admin_info.disable_password ? null : var.admin_info.password
  tags                  = var.tags
  custom_data           = var.cloud_init_info.enabled ? data.template_cloudinit_config.config[0].rendered : null

  os_disk {
    name                   = var.os_disk_info.name
    caching                = var.os_disk_info.caching
    disk_size_gb           = var.os_disk_info.size
    storage_account_type   = var.os_disk_info.storage_account_type
    disk_encryption_set_id = try(var.disk_encryption_set_id, null)
  }

  admin_ssh_key {
    username   = var.admin_info.username
    public_key = var.admin_info.public_key
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.admin_info.identities
  }

  source_image_reference {
    offer     = try(var.os_disk_info.image.offer, null)
    publisher = try(var.os_disk_info.image.publisher, null)
    sku       = try(var.os_disk_info.image.sku, null)
    version   = try(var.os_disk_info.image.version, null)
  }

  boot_diagnostics {
    storage_account_uri = try(var.os_disk_info.boot_diagnostics_storage_account, null)
  }

  lifecycle {
    ignore_changes = [
      identity,
      tags
    ]
  }

  depends_on = [azurerm_network_interface.nic]
}

resource "azurerm_managed_disk" "data_disk" {
  count                = var.data_disk_info.enabled ? 1 : 0
  name                 = var.data_disk_info.name
  location             = var.resource_group_info.location
  resource_group_name  = var.resource_group_info.name
  storage_account_type = var.data_disk_info.storage_account_type
  create_option        = var.data_disk_info.create_option
  disk_size_gb         = var.data_disk_info.size
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  managed_disk_id    = azurerm_managed_disk.data_disk[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = var.data_disk_info.lun
  caching            = var.data_disk_info.caching
}

resource "azurerm_virtual_machine_extension" "monitor_agent" {
  count                      = var.extension_info.monitor_agent.enabled ? 1 : 0
  name                       = "mon-agent-${var.vm_info.name}"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = var.extension_info.monitor_agent.version
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_info.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_info.workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count                      = var.extension_info.dependency_agent.enabled ? 1 : 0
  name                       = "depend-agent-${var.vm_info.name}"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = var.extension_info.dependency_agent.version
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_info.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_info.workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [azurerm_virtual_machine_extension.monitor_agent]
}
