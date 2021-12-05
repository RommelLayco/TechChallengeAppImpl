# Define providers

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


# Create VPC for eks cluster and rds

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
