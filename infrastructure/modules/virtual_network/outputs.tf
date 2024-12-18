output "subnets" {
  value = azurerm_subnet.subnets[*].id
}