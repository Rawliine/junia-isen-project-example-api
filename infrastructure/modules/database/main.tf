  resource "azurerm_mssql_server" "server" {
    name                        = "${var.database_name}-${var.suffix}"  # Nom du serveur SQL, combiné avec un suffixe pour garantir l'unicité
    resource_group_name         = var.resource_group_name             # Nom du groupe de ressources
    location                    = var.location                         # Localisation du serveur SQL
    version                     = "12.0"                               # Version de SQL Server (à ajuster selon les besoins)
    administrator_login         = var.admin_user                       # Nom d'utilisateur administrateur pour se connecter au serveur SQL
    administrator_login_password = var.admin_password                   # Mot de passe de l'administrateur pour se connecter au serveur SQL
  }





  resource "azurerm_mssql_database" "db" {
    name      = "${var.database_name}"  # Nom de la base de données, généré dynamiquement à partir des variables
    server_id = azurerm_mssql_server.server.id         # ID du serveur SQL sur lequel la base de données sera créée
  }


resource "azurerm_private_endpoint" "db_private_endpoint" {
  name                = "db-private-endpoint"               # Nom du point de terminaison privé
  location            = var.location                        # Localisation du point de terminaison privé
  resource_group_name = var.resource_group_name             # Nom du groupe de ressources
  subnet_id           = var.subnet_id                       # ID du sous-réseau dans lequel le point de terminaison privé sera déployé

  private_service_connection {
    name                           = "sql-private-connection"  # Nom de la connexion privée
    private_connection_resource_id = azurerm_mssql_server.server.id  # ID du serveur SQL auquel le point de terminaison privé se connecte
    subresource_names              = ["sqlServer"]            # Spécifie que la connexion est pour SQL Server
    is_manual_connection           = false                     # Connexion automatique (ne nécessite pas d'approbation manuelle)
  }
}

 


