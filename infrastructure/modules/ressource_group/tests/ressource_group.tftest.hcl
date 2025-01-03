

# Configuration du fournisseur AzureRM
provider "azurerm" {
  features {}
  subscription_id = "5c4b3bd7-e274-4e6a-96b2-144c158bbebb"  # Ton ID de souscription Azure
}

# Test pour vérifier la création du groupe de ressources
run "check_resource_group" {
  command = apply

  variables {
    resource_group_name = "Cloud-computing-project-86c14ca58087"
    location           = "northeurope"
    suffix             = "86c14ca58087"
  }

  # Vérifier que le groupe de ressources existe et que son nom est correct
  assert {
    condition     = azurerm_resource_group.rg.name == "${var.resource_group_name}-${var.suffix}"
    error_message = "Le nom du groupe de ressources est incorrect"
  }

  # Vérifier que le groupe de ressources est dans la bonne localisation
  assert {
    condition     = azurerm_resource_group.rg.location == var.location
    error_message = "La localisation du groupe de ressources est incorrecte"
  }
}
