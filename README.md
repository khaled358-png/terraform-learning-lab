# Terraform AWS Infrastructure Project

## Overview

This project provisions a complete AWS infrastructure using Terraform across two isolated environments: **dev** and **prod**.

Each environment is managed via its own `.tfvars` file and a dedicated Terraform Workspace, making it easy to deploy and destroy each environment independently without affecting the other.

---

## Architecture

```
                         Internet
                            │
                    ┌───────▼────────┐
                    │Internet Gateway│
                    └───────┬────────┘
                            │
                    ┌───────▼────────┐
                    │   VPC (10.0.0.0/16)  │
                    │                │
          ┌─────────┴──────┐  ┌──────┴──────────┐
          │  Public Subnet 1│  │ Public Subnet 2  │
          │  10.0.0.0/24   │  │  10.0.1.0/24    │
          │  (jump_box EC2)│  │                  │
          └────────┬───────┘  └─────────────────┘
                   │
           ┌───────▼──────┐
           │  NAT Gateway  │
           └───────┬───────┘
                   │
          ┌────────▼──────┐  ┌──────────────────┐
          │ Private Subnet1│  │ Private Subnet 2  │
          │  10.0.2.0/24  │  │  10.0.3.0/24     │
          │  (APP EC2)    │  │                   │
          └───────────────┘  └───────────────────┘
```

---

## Project Structure

```
.
├── provider.tf          # Terraform & AWS provider config
├── vpc.tf               # VPC resource
├── public-subnets.tf    # Public subnets (x2)
├── privet-subnet.tf     # Private subnets (x2)
├── internet-gatway.tf   # Internet Gateway
├── nat-gatway.tf        # NAT Gateway + Elastic IP
├── route-table.tf       # Route tables & associations
├── security_group.tf    # Security groups
├── ec2.tf               # EC2 instances (jump box + app server)
├── key-pair.tf          # SSH key pair + Secrets Manager
├── variable.tf          # Variable declarations
├── dev.tfvars           # Dev environment values
├── prod.tfvars          # Prod environment values
└── README.md
```

---

## Resources Created

| Resource | Description |
|---|---|
| `aws_vpc` | Main VPC with DNS enabled |
| `aws_subnet` x4 | 2 public + 2 private subnets across 2 AZs |
| `aws_internet_gateway` | Allows public subnets to reach the internet |
| `aws_nat_gateway` | Allows private subnets to reach the internet |
| `aws_eip` | Elastic IP attached to NAT Gateway |
| `aws_route_table` x2 | One public, one private |
| `aws_route_table_association` x4 | Links subnets to their route tables |
| `aws_security_group` x2 | SSH (public) + Internal (VPC only) |
| `aws_instance` x2 | `jump_box` in public, `APP` in private subnet |
| `aws_key_pair` | RSA 4096-bit SSH key pair |
| `aws_secretsmanager_secret` | Stores the private key securely |

---

## Environments

| Variable | dev | prod |
|---|---|---|
| `region` | `us-east-1` | `us-west-1` |
| `vpc_cidr` | `10.0.0.0/16` | `10.0.0.0/16` |
| `public_subnet1_cidr` | `10.0.0.0/24` | `10.0.0.0/24` |
| `public_subnet2_cidr` | `10.0.1.0/24` | `10.0.1.0/24` |
| `private_subnet1_cidr` | `10.0.2.0/24` | `10.0.2.0/24` |
| `private_subnet2_cidr` | `10.0.3.0/24` | `10.0.3.0/24` |
| `ami` | `ami-091138d0f0d41ff90` | `ami-091138d0f0d41ff90` |
| `instance_type` | `t2.micro` | `t2.micro` |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with valid credentials
- AWS account with permissions for: VPC, EC2, Secrets Manager

---

## Getting Started

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd <your-repo-folder>
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Create the Workspaces (one time only)

```bash
terraform workspace new dev
terraform workspace new prod
```

---

## Working with Workspaces

### Check your current workspace

```bash
terraform workspace show
```

### List all workspaces

```bash
terraform workspace list
```

### Switch between environments

```bash
# Switch to dev
terraform workspace select dev

# Switch to prod
terraform workspace select prod
```

> ⚠️ Always confirm which workspace you're on before running `apply` or `destroy`.

---

## Deploy

### Dev

```bash
terraform workspace select dev
terraform plan  -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

### Prod

```bash
terraform workspace select prod
terraform plan  -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

---

## Destroy

```bash
# Destroy dev
terraform workspace select dev
terraform destroy -var-file="dev.tfvars"

# Destroy prod
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
```

---

## Retrieving the SSH Private Key

The private key is stored automatically in AWS Secrets Manager after apply.

### Via AWS Console
Go to **Secrets Manager** → search for `ec2-ssh-private-key` → click **Retrieve secret value**

### Via AWS CLI

```bash
aws secretsmanager get-secret-value \
  --secret-id ec2-ssh-private-key \
  --query SecretString \
  --output text > my-key.pem

chmod 400 my-key.pem
```

### Connect to jump box

```bash
ssh -i my-key.pem ec2-user@<jump_box_public_ip>
```

### Connect to app server (via jump box)

```bash
ssh -i my-key.pem -J ec2-user@<jump_box_public_ip> ec2-user@<app_private_ip>
```

---

## Security Notes

- The `ssh_security` group currently allows SSH from `0.0.0.0/0` — restrict this to your own IP in production
- The `internal_security` group only allows traffic from within the VPC
- Private key never touches disk — it goes directly from Terraform state to Secrets Manager
- NAT Gateway has an hourly AWS cost — destroy dev when not in use
