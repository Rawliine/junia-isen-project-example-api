variable "app_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "app_service_plan_name" {}
variable "virtual_network_subnet_id" {}

variable "suffix" {
  description = "Le suffixe aléatoire pour nommer la base de données"
  type        = string
}

