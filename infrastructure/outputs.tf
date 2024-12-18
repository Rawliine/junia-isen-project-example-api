output "app_name"{
    value = module.backend_app.app_name
}


output "sql_connection_string" {
  value = module.database.sql_connection_string
}

output "rg_name"{
    value = module.resource_group.name
}

output "server_name"{
    value = module.database.server_name
}
