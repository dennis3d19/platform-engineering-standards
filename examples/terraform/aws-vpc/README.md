# Terraform Example: AWS VPC

This example demonstrates a production-grade AWS VPC configuration following the
[Terraform Standards](../../docs/standards/terraform-standards.md).

---

## What This Creates

- VPC with configurable CIDR block
- Public, private, and database subnets across 3 availability zones
- Internet Gateway for public subnets
- NAT Gateway for private subnet internet egress
- VPC Flow Logs enabled for network audit
- DNS support and DNS hostnames enabled

## Prerequisites

- Terraform >= 1.9
- AWS credentials configured (via IAM role, environment variables, or profile)
- AWS provider access to create VPC resources

## Usage

```bash
cd examples/terraform/aws-vpc

# Initialise with backend (for demonstration, using local backend)
terraform init

# Plan
terraform plan -var-file=terraform.tfvars.example

# Apply (review plan first)
terraform apply -var-file=terraform.tfvars.example
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `environment` | `string` | Yes | — | Environment name (tst, acc, prd) |
| `application` | `string` | Yes | — | Application or team name |
| `region` | `string` | Yes | — | AWS region |
| `vpc_cidr` | `string` | No | `10.0.0.0/16` | VPC CIDR block |
| `enable_nat_gateway` | `bool` | No | `true` | Enable NAT Gateway for private subnets |
| `single_nat_gateway` | `bool` | No | `false` | Use a single NAT Gateway (cost saving for non-prod) |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC identifier |
| `vpc_cidr_block` | VPC CIDR block |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnet_ids` | List of public subnet IDs |

## Security Considerations

- VPC Flow Logs are enabled by default to capture all network traffic
- Network ACLs provide subnet-level traffic filtering
- Security groups should be defined by consuming modules — this module provides no SGs
- Private subnets have no direct internet access; all outbound goes through NAT Gateway

## Production Considerations

- Use multiple NAT Gateways (`single_nat_gateway = false`) in production for AZ resilience
- VPC CIDR must not overlap with other VPCs that will be peered
- Flow logs are stored in CloudWatch Logs; set appropriate retention and consider cost
