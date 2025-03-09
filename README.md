# AWS EKS Cluster Terraform Configuration

This Terraform configuration creates an Amazon EKS (Elastic Kubernetes Service) cluster using an existing VPC. It utilizes the official [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) module to provision the cluster and managed node groups.

## Prerequisites

- Terraform >= 1.0
- AWS account and credentials configured
- Existing VPC with private subnets tagged with `Tier = "Private"`
- AWS CLI (optional, for kubectl configuration)

## Features

- Creates an EKS cluster in your existing VPC
- Provisions managed node groups with customizable configuration
- Supports both ON_DEMAND and SPOT capacity types
- Configurable cluster version and node instance types
- Comprehensive tagging support
- OIDC provider integration

## Usage

1. Clone this repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Copy the example variables file and modify it with your values:
```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Update `terraform.tfvars` with your specific configuration:
```hcl
region         = "us-west-2"
vpc_id         = "vpc-12345678" # Your VPC ID
cluster_name   = "my-eks-cluster"
cluster_version = "1.27"
environment    = "dev"

# Node group configuration
desired_size    = 2
min_size        = 1
max_size        = 3
instance_types  = ["t3.medium"]
capacity_type   = "ON_DEMAND"

tags = {
  Environment = "dev"
  Terraform   = "true"
  Project     = "my-project"
  Owner       = "team-name"
}
```

4. Initialize Terraform:
```bash
terraform init
```

5. Review the planned changes:
```bash
terraform plan
```

6. Apply the configuration:
```bash
terraform apply
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region | `string` | `"us-west-2"` | no |
| vpc_id | ID of the existing VPC | `string` | n/a | yes |
| cluster_name | Name of the EKS cluster | `string` | `"my-eks-cluster"` | no |
| cluster_version | Kubernetes version to use for the EKS cluster | `string` | `"1.27"` | no |
| environment | Environment name for the cluster | `string` | `"dev"` | no |
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
| cluster_iam_role_name | IAM role name of the EKS cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster_name | The name of the EKS cluster |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider |
| cluster_version | The Kubernetes version for the EKS cluster |
| cluster_addons | Map of attribute maps for all EKS cluster addons enabled |
| eks_managed_node_groups | Map of attribute maps for all EKS managed node groups created |

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
2. The cluster endpoint is configured for public access by default. Modify `cluster_endpoint_public_access` in `main.tf` if you need to change this.
3. Node groups use the latest Amazon Linux 2 EKS-optimized AMI by default.
4. OIDC provider is enabled by default for service account integration.

## Security Considerations

- The cluster endpoint is publicly accessible by default. Consider setting `cluster_endpoint_public_access = false` for production environments.
- Use appropriate IAM roles and security groups for production deployments.
- Consider enabling control plane logging for better visibility.
- Review and adjust the security group rules as needed.

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