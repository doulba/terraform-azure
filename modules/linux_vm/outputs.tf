output "public_ip" {
  description = "The Primary Public IP Address assigned to this Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "private_ip" {
  description = "The Primary Private IP Address assigned to this Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "The ID of the Linux Virtual Machine."
}
