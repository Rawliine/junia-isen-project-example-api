# Configuration du fournisseur AzureRM
provider "azurerm" {
  features {}
  subscription_id = "5c4b3bd7-e274-4e6a-96b2-144c158bbebb"  # Ton ID de souscription Azure
}


run "check_service_plan" {
  command = apply

  variables {
  suffix                   = "86c14ca58087"
    app_service_plan_name    = "example-86c14ca58087"
    app_name                 = "backend-app"
    virtual_network_subnet_id = "/subscriptions/5c4b3bd7-e274-4e6a-96b2-144c158bbebb/resourceGroups/Cloud-computing-project-86c14ca58087/providers/Microsoft.Network/virtualNetworks/vnet-10-0-0-0-16/subnets/backend-subnet"
    resource_group_name      = "Cloud-computing-project-86c14ca58087"
    location                 = "northeurope"
    sql_connection_string    = "mssql+pyodbc:///?odbc_connect=Driver={ODBC Driver 18 for SQL Server};Server=tcp:baceugeu-market-db-86c14ca58087.database.windows.net,1433;Database=userdb;Uid=adminuser;Pwd={P@ssword123};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
  }

  # Vérifier que le Service Plan existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_service_plan.example.name == "${var.app_service_plan_name}-${var.suffix}"
    error_message = "Le nom du Service Plan est incorrect"
  }

  assert {
    condition     = azurerm_service_plan.example.sku_name == "B1"
    error_message = "Le SKU du Service Plan est incorrect"
  }

  assert {
    condition     = azurerm_service_plan.example.os_type == "Linux"
    error_message = "Le type d'OS du Service Plan est incorrect"
  }
}



run "check_linux_web_app" {
  command = apply

  variables {
    app_name               = var.app_name
    resource_group_name    = var.resource_group_name
    location               = var.location
    suffix                 = var.suffix
    virtual_network_subnet_id = var.virtual_network_subnet_id
    service_plan_id        = var.service_plan_id
    DATABASE_URL          = var.DATABASE_URL
  }

  # Vérifier que l'application web existe et que ses propriétés sont correctes
  assert {
    condition     = azurerm_linux_web_app.app.name == "${var.app_name}-${var.suffix}"
    error_message = "Le nom de l'application web est incorrect"
  }

  assert {
    condition     = azurerm_linux_web_app.app.service_plan_id == var.service_plan_id
    error_message = "L'ID du plan de service de l'application web est incorrect"
  }

  assert {
    condition     = azurerm_linux_web_app.app.site_config[0].always_on == false
    error_message = "La configuration 'always_on' de l'application web est incorrecte"
  }

  assert {
    condition     = azurerm_linux_web_app.app.app_settings["DATABASE_URL"] == var.DATABASE_URL
    error_message = "L'URL de la base de données dans les paramètres de l'application est incorrect"
  }
}


