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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.envoy_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.envoy_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.envoy_cluster.token
}

data "aws_eks_cluster" "envoy_cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "envoy_cluster" {
  name = module.eks.cluster_id
}


#########################################
#               CREATE VPC              #
#########################################

locals {
  # We create 4 subnets, 2 private and 2 public
  # Deploy the subnet into different az for HA
  subnets           = cidrsubnets(var.vpc_cidr, 2, 2, 2, 2)
  full_cluster_name = "${var.name}-cluster"

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

  ingress {
    description      = "Allow database connections froom within VPC"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

}

#########################################
#             CREATE EKS                #
#########################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.24"

  cluster_name    = local.full_cluster_name
  cluster_version = var.k8s_version
  subnets         = module.vpc.private_subnets

  vpc_id           = module.vpc.vpc_id
  write_kubeconfig = false
  enable_irsa      = true

  cluster_enabled_log_types = [
    "audit",
    "authenticator",
  ]

  node_groups_defaults = {
    create_launch_template = true
    disk_encrypted         = true
    disk_size              = 20
    disk_type              = "gp3"
    disk_kms_key_id        = data.aws_kms_alias.ebs_service_key.target_key_arn
    ebs_optimized          = true
    key_name               = aws_key_pair.worker_node_key_pair.key_name
  }

  node_groups = [
    {
      ami_type         = "AL2_x86_64"
      name_prefix      = "intel-m5-"
      instance_types   = ["m5.xlarge"]
      desired_capacity = 2
      min_capacity     = 2
      max_capacity     = 3
      additional_tags = {
        Name = "${local.full_cluster_name}-intel-m5"
      }
    }
  ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KubeAdmin"
      username = "KubeAdmin"
      groups = [
        "system:masters"
      ]
    }
  ]
}

resource "aws_key_pair" "worker_node_key_pair" {
  key_name   = "${local.full_cluster_name}/KEY"
  public_key = var.ssh_public_key_value
}

data "aws_caller_identity" "current" {}

data aws_kms_alias ebs_service_key {
  name = "alias/aws/ebs"
}
