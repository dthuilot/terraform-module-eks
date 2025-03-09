provider "aws" {
  region = local.region
}

locals {
  region = "us-west-2"
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

data "aws_availability_zones" "available" {}

################################################################################
# Cluster
################################################################################

module "eks" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Cluster access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Enable IRSA
  enable_irsa = true

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    default = {
      name = "node-group-1"

      instance_types = ["t3.medium"]
      ami_type       = "AL2_x86_64"

      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Needed for Karpenter
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
} 