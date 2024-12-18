# Configuration du fournisseur AzureRM
provider "azurerm" {
  features {}
  subscription_id = "5c4b3bd7-e274-4e6a-96b2-144c158bbebb"  # Ton ID de souscription Azure
}


# Test pour vérifier la création du serveur SQL
run "check_mssql_server" {
  command = apply

  variables {
    database_name      = var.database_name
    resource_group_name = var.resource_group_name
    location           = var.location
    suffix             = var.suffix
    admin_user         = var.admin_user
    admin_password     = var.admin_password
    subnet_id          = var.subnet_id
  }

  # Vérifier que le serveur SQL existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_mssql_server.server.name == "${var.database_name}-${var.suffix}"
    error_message = "Le nom du serveur SQL est incorrect"
  }

  assert {
    condition     = azurerm_mssql_server.server.administrator_login == var.admin_user
    error_message = "Le nom d'utilisateur administrateur du serveur SQL est incorrect"
  }

  assert {
    condition     = azurerm_mssql_server.server.version == "12.0"
    error_message = "La version du serveur SQL est incorrecte"
  }
}

# Test pour vérifier la création de la base de données
run "check_mssql_database" {
  command = apply

  variables {
    database_name      = var.database_name
    resource_group_name = var.resource_group_name
    location           = var.location
    suffix             = var.suffix
  }

  # Vérifier que la base de données existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_mssql_database.db.name == "${var.database_name}-${var.suffix}"
    error_message = "Le nom de la base de données est incorrect"
  }

  assert {
    condition     = azurerm_mssql_database.db.server_id == azurerm_mssql_server.server.id
    error_message = "Le serveur de la base de données est incorrect"
  }
}

# Test pour vérifier la création du Private Endpoint
run "check_private_endpoint" {
  command = apply

  variables {
    resource_group_name = var.resource_group_name
    location           = var.location
    subnet_id          = var.subnet_id
  }

  # Vérifier que le Private Endpoint existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_private_endpoint.db_private_endpoint.name == "db-private-endpoint"
    error_message = "Le nom du Private Endpoint est incorrect"
  }

  assert {
    condition     = azurerm_private_endpoint.db_private_endpoint.private_service_connection[0].private_connection_resource_id == azurerm_mssql_server.server.id
    error_message = "L'ID de la connexion privée du Private Endpoint est incorrect"
  }

  assert {
    condition     = azurerm_private_endpoint.db_private_endpoint.private_service_connection[0].subresource_names[0] == "sqlServer"
    error_message = "Le sous-ressource du Private Endpoint est incorrect"
  }

  assert {
    condition     = azurerm_private_endpoint.db_private_endpoint.private_service_connection[0].is_manual_connection == false
    error_message = "La connexion manuelle du Private Endpoint est incorrecte"
  }
}
