output "db_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_host" {
  value = module.db.db_instance_address
}

output "db_port" {
  value = module.db.db_instance_port
}

output "db_name" {
  value = module.db.db_instance_name
}

output "db_user" {
  value = nonsensitive(module.db.db_instance_username)
}
