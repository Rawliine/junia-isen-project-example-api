resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${var.suffix}"  # Nom du groupe de ressources, combiné avec un suffixe pour garantir l'unicité
  location = var.location  # La région Azure où le groupe de ressources sera créé
}
