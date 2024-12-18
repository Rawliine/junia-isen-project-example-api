terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_id" "suffix" {
  byte_length = 6
}



module "resource_group" {
  source = "./modules/ressource_group"
  resource_group_name = "Cloud-computing-project"
  location            = var.location
  suffix             = random_id.suffix.hex

}
  
module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = module.resource_group.name
  location            = var.location
  vnet_name           = "vnet-10-0-0-0-16"
  address_space       = "10.0.0.0/16"
}


      
module "backend_app" {
  source                  = "./modules/backend"
  app_name                = "backend-app"
  app_service_plan_name   = "example"
  resource_group_name     = module.resource_group.name
  location                = var.location
  virtual_network_subnet_id = module.virtual_network.subnets[0]
  suffix             = random_id.suffix.hex
}

module "database" {
  source              = "./modules/database"
  database_name       = "baceugeu-market-db"
  resource_group_name = module.resource_group.name
  location            = var.location
  admin_user          = "adminuser"
  admin_password      = "P@ssword123"
  subnet_id           = module.virtual_network.subnets[1]  # ID du subnet 'database-subnet' 
  suffix             = random_id.suffix.hex
}

