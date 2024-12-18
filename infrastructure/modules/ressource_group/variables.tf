variable "resource_group_name" {
  description = "Le nom de base du groupe de ressources"
  type        = string
}

variable "location" {
  description = "La localisation du groupe de ressources"
  type        = string
}

variable "suffix" {
  description = "Le suffixe aléatoire pour nommer le groupe de ressources"
  type        = string
}
