terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Tier = "Private"
  }
}

locals {
  name = var.cluster_name
  tags = merge(var.tags, {
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "dthuilot"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version
  cluster_endpoint_public_access  = true
 
  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = var.vpc_id
  subnet_ids = data.aws_subnets.private.ids

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    default = {
      name = "general"

      ami_type       = var.ami_type
      instance_types = var.instance_types

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # Needed for Karpenter
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  # Enable IRSA
  enable_irsa = true

  # Enable AWS Auth configmap
  enable_cluster_creator_admin_permissions = true

  tags = local.tags
} 