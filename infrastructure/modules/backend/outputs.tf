output "app_name" {
  value = azurerm_linux_web_app.app.name
}

output "virtual_network_subnet_id" {
  value = azurerm_linux_web_app.app.virtual_network_subnet_id
}

output "app_settings" {
  value = azurerm_linux_web_app.app.app_settings
}

output "app_service_plan_name" {
  value = azurerm_service_plan.example.name
}

output "linux_web_app_name" {
  value = azurerm_linux_web_app.app.name
}


output "app_service_plan_id" {
  value = azurerm_service_plan.example.id
}

