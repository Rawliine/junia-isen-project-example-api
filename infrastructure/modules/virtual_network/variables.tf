variable "vnet_name" {}
variable "address_space" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnets" {
  description = "List of subnets to be created"
  type = list(object({
    name            = string
    address_prefix  = string
    delegation      = optional(object({
      name             = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
  default = [
    {
      name           = "backend-subnet"
      address_prefix = "10.0.1.0/24"
      delegation = {
        name = "Microsoft.Web/serverFarms"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    },
    {
      name           = "database-subnet"
      address_prefix = "10.0.2.0/24"
      # Pas de délégation ici pour la base de données
    },
    {
      name           = "database-monitoring"
      address_prefix = "10.0.3.0/24"
      # Pas de délégation ici pour le monitoring
    }
  ]
}
