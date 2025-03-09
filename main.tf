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

data "aws_vpc" "existing" {
  id = var.vpc_id
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Cluster access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # Enable cluster encryption
  enable_cluster_encryption = true
  cluster_encryption_config = {
    provider_key_arn = var.cluster_encryption_key_arn
    resources        = ["secrets"]
  }

  # Enable OIDC provider
  enable_irsa = true

  # VPC Configuration
  vpc_id     = var.vpc_id
  subnet_ids = data.aws_subnets.private.ids

  # Cluster security group
  create_cluster_security_group = true
  create_node_security_group   = true

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    general = {
      name = "general-node-group"

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      # Use latest EKS optimized AMI
      ami_type = "AL2_x86_64"
      
      # Enable node group autoscaling
      enable_monitoring = true

      # Add required tags
      labels = {
        Environment = var.environment
        NodeGroup   = "general"
      }

      tags = var.tags
    }
  }

  # Enable EKS add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # Enable AWS Auth configmap
  enable_cluster_creator_admin_permissions = true
  
  # Add tags to all resources
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      GithubRepo                                  = "terraform-aws-eks"
      GithubOrg                                   = "terraform-aws-modules"
    }
  )
} 