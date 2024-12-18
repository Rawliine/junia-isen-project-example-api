variable "database_name" {
  description = "Le nom de la base de données SQL"
  type        = string
}

variable "resource_group_name" {
  description = "Le nom du groupe de ressources"
  type        = string
}

variable "location" {
  description = "La localisation des ressources"
  type        = string
}

variable "admin_user" {
  description = "Nom d'utilisateur pour l'administrateur SQL"
  type        = string
}

variable "admin_password" {
  description = "Mot de passe pour l'administrateur SQL"
  type        = string
}



variable "subnet_id" {
  description = "L'ID du subnet où déployer le Private Endpoint"
  type        = string
}

variable "suffix" {
  description = "Le suffixe aléatoire pour nommer la base de données"
  type        = string
}

