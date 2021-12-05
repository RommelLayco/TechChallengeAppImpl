variable "name" {
  type        = string
  description = "Name of the application. This is used to name infrastructure resources"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile used to deploy infrastructure"
}

variable "region" {
  type        = string
  description = "AWS region to deloy application"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "192.168.0.0/16"
}

variable "default_db_name" {
  type = string
  description = "Name of the default database for postgres RDS"
  default = "app"  
}

variable "db_admin_user" {
  type = string
  description = "Name of the default admin username for postgres RDS"
  default = "postgres"  
}

variable "db_admin_password" {
  type = string
  description = "Password for the default admin user"
}

variable "db_instance_type" {
  type = string
  description = "The instance type of the postgres RDS"
  default = "db.t2.large"
}

variable "db_storage" {
  type = number
  description = "Size of the postgres RDS storage in GiB"
  default = 10
  }

variable "maintenance_window" {
  type = string
  description = "Maintenace Period of postgres RDS instance"
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type = string
  description = "automated backup window of postgres RDS instance"
  default = "03:00-06:00"
}

# variable "cluster_name" {
#   type        = string
#   description = "Name of the cluster"
# }


# variable "k8s_version" {
#   type        = string
#   description = "Name of the cluster"
# }

# variable "ssh_public_key_value" {
#   type        = string
#   description = "The public key value used to ssh to worker nodes"
# }

# variable "node_group_configuration" {
#   type = any
#   description = "Configuration values for node groups"
#   default = {}
# }
