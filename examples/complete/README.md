# Complete EKS Cluster with VPC

Configuration in this directory creates:
- A new VPC with public and private subnets
- An EKS cluster with managed node groups
- Required IAM roles and security groups
- IRSA configuration
- EKS add-ons (CoreDNS, kube-proxy, vpc-cni)

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| kubernetes | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| eks | ../../ | n/a |
| vpc | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | The Amazon Resource Name (ARN) of the cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster_endpoint | Endpoint for your Kubernetes API server |
| cluster_id | The ID of the EKS cluster |
| cluster_name | The name of the EKS cluster |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider |
| cluster_platform_version | Platform version for the cluster |
| cluster_status | Status of the EKS cluster |
| cluster_version | The Kubernetes version for the cluster |
| cluster_security_group_arn | Amazon Resource Name (ARN) of the cluster security group |
| cluster_security_group_id | ID of the cluster security group |
| node_security_group_arn | Amazon Resource Name (ARN) of the node shared security group |
| node_security_group_id | ID of the node shared security group |
| oidc_provider | The OpenID Connect identity provider |
| oidc_provider_arn | The ARN of the OIDC Provider |
| cluster_iam_role_name | IAM role name of the EKS cluster |
| cluster_iam_role_arn | IAM role ARN of the EKS cluster |
| cluster_iam_role_unique_id | Stable and unique string identifying the IAM role |
| eks_managed_node_groups | Map of attribute maps for all EKS managed node groups created |
| eks_managed_node_groups_autoscaling_group_names | List of the autoscaling group names created by EKS managed node groups |
| aws_auth_configmap_yaml | Formatted yaml output for base aws-auth configmap | 