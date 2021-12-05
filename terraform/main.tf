#########################################
#          DEFINE PROVIDERS             #
#########################################

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      WorkspaceName = terraform.workspace
      Terraform     = true
      Stack         = "TechChallenge"
    }
  }
}

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.envoy_cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.envoy_cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.envoy_cluster.token
# }

# data "aws_eks_cluster" "envoy_cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "envoy_cluster" {
#   name = module.eks.cluster_id
# }


#########################################
#               CREATE VPC              #
#########################################

locals {
  # We create 4 subnets, 2 private and 2 public
  # Deploy the subnet into different az for HA
  subnets = cidrsubnets(var.vpc_cidr, 2, 2, 2, 2)

}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.11"

  name = var.name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = slice(local.subnets, 0, 2)
  public_subnets  = slice(local.subnets, 2, 4)

  enable_nat_gateway = true

}


#########################################
#             CREATE RDS                #
#########################################

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = lower(var.name)

  engine               = "postgres"
  engine_version       = "10.7"
  family               = "postgres10"
  major_engine_version = "10"

  instance_class    = var.db_instance_type
  allocated_storage = var.db_storage
  multi_az          = true

  name     = var.default_db_name
  username = var.db_admin_user
  password = var.db_admin_password
  port     = "5432"


  vpc_security_group_ids = [aws_security_group.aws_security_group.id]

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  # DB subnet group
  subnet_ids = module.vpc.private_subnets

}

resource "aws_security_group" "aws_security_group" {
  name_prefix = "${var.name}-db-sg-"
  description = "Security group attached to RDS instance"
  vpc_id      = module.vpc.vpc_id

}
