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

# variable "cluster_name" {
#   type        = string
#   description = "Name of the cluster"
# }

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "192.168.0.0/16"
}

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
