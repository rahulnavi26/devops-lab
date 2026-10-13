output "public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.main.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.main.admin_password
  sensitive = true # show with: terraform output -raw acr_admin_password
}

output "ssh_command" {
  value = "ssh ubuntu@${azurerm_public_ip.main.ip_address}"
}

output "app_url" {
  value = "http://${azurerm_public_ip.main.ip_address}:30080"
}

output "grafana_url" {
  value = "http://${azurerm_public_ip.main.ip_address}:30030"
}
