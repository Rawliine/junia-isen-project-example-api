# Configuration du fournisseur AzureRM
provider "azurerm" {
  features {}
  subscription_id = "5c4b3bd7-e274-4e6a-96b2-144c158bbebb"  # Ton ID de souscription Azure
}


# Test pour vérifier la création du réseau virtuel
run "check_virtual_network" {
  command = apply

  variables {
    vnet_name            = var.vnet_name
    address_space        = var.address_space
    location             = var.location
    resource_group_name  = var.resource_group_name
  }

  # Vérifier que le réseau virtuel existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_virtual_network.vnet.name == var.vnet_name
    error_message = "Le nom du réseau virtuel est incorrect"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.address_space == var.address_space
    error_message = "L'espace d'adresses du réseau virtuel est incorrect"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.location == var.location
    error_message = "La localisation du réseau virtuel est incorrecte"
  }
}


run "check_subnets" {
  command = apply

  variables {
    subnets              = var.subnets
    resource_group_name  = var.resource_group_name
    vnet_name            = var.vnet_name
  }

  # Vérifier que les sous-réseaux existent et que leurs propriétés sont correctes
  assert {
    condition     = azurerm_subnet.subnets[0].name == var.subnets[0].name
    error_message = "Le nom du sous-réseau est incorrect"
  }

  assert {
    condition     = azurerm_subnet.subnets[0].address_prefixes[0] == var.subnets[0].address_prefix
    error_message = "Le préfixe d'adresse du sous-réseau est incorrect"
  }

  # Vérifier la délégation si elle existe
  assert {
    condition     = azurerm_subnet.subnets[0].delegation != null
    error_message = "La délégation du sous-réseau est incorrecte"
  }
}