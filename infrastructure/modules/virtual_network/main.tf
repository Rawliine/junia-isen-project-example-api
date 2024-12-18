resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name                # Nom du réseau virtuel
  address_space       = [var.address_space]          # Plage d'adresses IP du réseau virtuel
  location            = var.location                 # Région Azure où le réseau virtuel sera créé
  resource_group_name = var.resource_group_name      # Nom du groupe de ressources où le réseau virtuel sera déployé
}


resource "azurerm_subnet" "subnets" {
  count                = length(var.subnets)                           # Crée un sous-réseau pour chaque élément de la variable `subnets`
  name                 = var.subnets[count.index].name                # Nom du sous-réseau, défini dynamiquement à partir de la variable `subnets`
  resource_group_name  = var.resource_group_name                      # Nom du groupe de ressources où le sous-réseau sera créé
  virtual_network_name = azurerm_virtual_network.vnet.name            # Nom du réseau virtuel auquel le sous-réseau appartient
  address_prefixes     = [var.subnets[count.index].address_prefix]    # Plage d'adresses IP du sous-réseau, définie dynamiquement à partir de la variable `subnets`

  # Délégation pour le backend (App Service)
  dynamic "delegation" {
    for_each = var.subnets[count.index].delegation != null ? [var.subnets[count.index].delegation] : []  # Vérifie si une délégation est définie pour le sous-réseau
    content {
      name = delegation.value.name  # Nom de la délégation de service

      service_delegation {
        name    = delegation.value.service_delegation.name       # Nom du service de délégation (par exemple, App Service)
        actions = delegation.value.service_delegation.actions    # Actions autorisées pour le service délégué
      }
    }
  }
}


