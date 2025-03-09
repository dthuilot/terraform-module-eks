# AWS EKS Cluster Terraform Configuration

This Terraform configuration creates an Amazon EKS (Elastic Kubernetes Service) cluster using an existing VPC. It utilizes the official [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module version 20.34.0 to provision the cluster and managed node groups.

## Prerequisites

- Terraform >= 1.0
- AWS account and credentials configured
- Existing VPC with private subnets tagged with `Tier = "Private"`
- AWS CLI (optional, for kubectl configuration)

## Features

- Creates an EKS cluster with configurable settings
- Provisions managed node groups with customizable configuration
- Supports both ON_DEMAND and SPOT capacity types
- Configurable cluster version and node instance types
- IRSA (IAM Roles for Service Accounts) support
- Cluster encryption using KMS
- EKS add-ons management (CoreDNS, kube-proxy, vpc-cni)
- AWS Auth configmap management
- Comprehensive security group configuration
- Flexible endpoint access configuration

## Module Usage

### Basic Example

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]

  # Enable IRSA
  enable_irsa = true

  # Node groups configuration
  eks_managed_node_groups = {
    general = {
      name = "general-node-group"

      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

### Advanced Example with Multiple Node Groups and SPOT Instances

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]

  # Cluster access configuration
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Enable cluster encryption
  enable_cluster_encryption = true
  cluster_encryption_config = {
    provider_key_arn = "arn:aws:kms:region:account:key/key-id"
    resources        = ["secrets"]
  }

  # Enable IRSA
  enable_irsa = true

  # Node groups configuration
  eks_managed_node_groups = {
    # On-demand node group for critical workloads
    critical = {
      name = "critical-workloads"

      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = "production"
        NodeGroup   = "critical"
        Workload    = "critical"
      }
    }

    # Spot instances for cost optimization
    spot = {
      name = "spot-workloads"

      min_size     = 1
      max_size     = 10
      desired_size = 2

      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"

      labels = {
        Environment = "production"
        NodeGroup   = "spot"
        Workload    = "general"
      }
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

  tags = {
    Environment = "production"
    Terraform   = "true"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region | `string` | `"us-west-2"` | no |
| vpc_id | ID of the existing VPC | `string` | n/a | yes |
| cluster_name | Name of the EKS cluster | `string` | `"my-eks-cluster"` | no |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | `"1.28"` | no |
| environment | Environment name for the cluster | `string` | `"dev"` | no |
| cluster_endpoint_public_access | Enable public API server endpoint access | `bool` | `true` | no |
| cluster_endpoint_private_access | Enable private API server endpoint access | `bool` | `true` | no |
| cluster_encryption_key_arn | ARN of the KMS key used for cluster encryption | `string` | `null` | no |
| desired_size | Desired number of worker nodes | `number` | `2` | no |
| min_size | Minimum number of worker nodes | `number` | `1` | no |
| max_size | Maximum number of worker nodes | `number` | `3` | no |
| instance_types | List of instance types for the EKS managed node group | `list(string)` | `["t3.medium"]` | no |
| capacity_type | Type of capacity associated with the EKS Node Group | `string` | `"ON_DEMAND"` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{ Environment = "dev", Terraform = "true" }` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_iam_role_arn | IAM role ARN of the EKS cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster_name | The name of the EKS cluster |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider |
| oidc_provider_arn | The ARN of the OIDC Provider |
| cluster_version | The Kubernetes version for the EKS cluster |
| cluster_addons | Map of attribute maps for all EKS cluster addons enabled |
| eks_managed_node_groups | Map of attribute maps for all EKS managed node groups created |
| aws_auth_configmap_yaml | Formatted yaml output for aws-auth configmap |

## Connecting to the Cluster

After the cluster is created, you can configure kubectl to connect to your cluster:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

Verify the connection:
```bash
kubectl get nodes
```

## Important Notes

1. The VPC must have private subnets tagged with `Tier = "Private"` for the EKS cluster.
2. The cluster endpoint is configured for both public and private access by default.
3. Node groups use the latest Amazon Linux 2 EKS-optimized AMI by default.
4. IRSA (IAM Roles for Service Accounts) is enabled by default.
5. Cluster encryption is enabled by default for secrets.
6. AWS Auth configmap is configured to allow cluster creator admin permissions.

## Security Best Practices

1. **Endpoint Access**:
   - Consider disabling public endpoint access in production environments
   - Enable private endpoint access for internal communication

2. **Node Security**:
   - Use the latest EKS-optimized AMI
   - Enable node group monitoring
   - Implement proper security groups

3. **Encryption**:
   - Enable cluster encryption for secrets
   - Use customer-managed KMS keys for better control

4. **Authentication**:
   - Use IRSA for pod-level IAM permissions
   - Properly configure aws-auth configmap
   - Implement least privilege access

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## References

- [EKS Module Documentation](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Terraform Documentation](https://www.terraform.io/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/) 