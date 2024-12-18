resource "azurerm_service_plan" "example" {
  name                = "${var.app_service_plan_name}-${var.suffix}"  # Nom du plan de service, basé sur les variables définies
  resource_group_name = var.resource_group_name                      # Nom du groupe de ressources
  location            = var.location                                  # Localisation du plan de service
  os_type             = "Linux"                                        # Type d'OS (ici Linux)
  sku_name            = "B1"                                           # SKU (niveau de performance), ici B1 (niveau de base)
}


resource "azurerm_linux_web_app" "app" {
  name                = "${var.app_name}-${var.suffix}"              # Nom de l'application, basé sur les variables définies
  resource_group_name = var.resource_group_name                      # Nom du groupe de ressources
  location            = var.location                                  # Localisation de l'application
  service_plan_id     = azurerm_service_plan.example.id              # ID du plan de service Azure App Service

  site_config {
    always_on = false  # Détermine si l'application doit être toujours active. Ici, elle n'est pas activée.
  }

  virtual_network_subnet_id = var.virtual_network_subnet_id  # ID du sous-réseau du réseau virtuel

}


