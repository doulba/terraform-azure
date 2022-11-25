resource "azurerm_resource_group" "rgp_touba" {
  name     = "rgp-dev-uccak-we1"
  location = "West Europe"
}

module "vm_sg1" {
  source = "../modules/linux_vm"
  resource_group_info = azurerm_resource_group.rgp_touba
  vm_info = {
    name          = "vm-ux-sg1-touba"
    computer_name = "sg1"
    size          = "Standard_F2"
    public_ip     = false
  }
  admin_info = {
    identities = []
    username   = "azadmin"
    public_key = ""
  }
  os_disk_info = {
    name                                  = "disk-vm-ux-sg1-touba"
    size                                  = 100
    caching                               = "ReadWrite"
    storage_account_type                  = "Premium_LRS"
    boot_diagnostics_storage_account_name = ""
    image = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "20.04-LTS"
      version   = "latest"
    }
  }
  network_info = {
    subnet_id         = ""
    security_group_id = ""
  }
}
