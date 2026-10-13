# Terraform AWS Multi-Environment Infrastructure

Reusable Terraform modules for provisioning AWS infrastructure across multiple environments (dev, staging, prod), with remote state stored in S3.

## Features

- Remote state in S3 with versioning, encryption, and native state locking (`use_lockfile`)
- Reusable modules shared across environments (no copy-paste)
- Separate state per environment
- VPC with public and private subnets across multiple Availability Zones
- Environment-specific settings through `terraform.tfvars`

## Project Structure

```
terraform/
├── bootstrap/          # One-time setup: S3 bucket for remote state (local state)
├── modules/
│   ├── vpc/            # VPC, subnets, route tables, internet/NAT gateways
│   └── compute/        # Compute resources
├── environments/
│   ├── dev/            # Dev root config (backend, main.tf, variables.tf, tfvars)
│   ├── staging/
│   └── prod/
└── README.md
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.10
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with a profile that has sufficient permissions
- An AWS account

Verify your setup:

```bash
terraform version
aws sts get-caller-identity
```

## Getting Started

### 1. Bootstrap the remote state bucket

The bootstrap config creates the S3 bucket that stores state for all environments. It uses local state because the bucket doesn't exist yet.

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

### 2. Deploy an environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

Terraform loads `terraform.tfvars` automatically. Use `-var-file=<name>.tfvars` only for differently named files.

### 3. Destroy an environment

```bash
cd environments/dev
terraform destroy
```

Destroy environments before the bootstrap. Destroying the state bucket while environments still use it will lose their state.

## Remote State

| Environment | State key                |
|-------------|--------------------------|
| dev         | `dev/terraform.tfstate`  |
| staging     | `staging/terraform.tfstate` |
| prod        | `prod/terraform.tfstate` |

Backend settings live in each environment's `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "<your-state-bucket>"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

## Modules

### `modules/vpc`

| Input      | Description                    |
|------------|--------------------------------|
| `vpc_cidr` | CIDR block for the VPC         |
| `env`      | Environment name used in tags  |

Outputs include the VPC ID and subnet IDs.

## Conventions

- Provider versions are pinned (`~> 6.0`) and the lock file (`.terraform.lock.hcl`) is committed
- Run `terraform fmt` and `terraform validate` before committing
- State files, `.terraform/`, and secret tfvars are excluded through `.gitignore`

## Security Notes

- Never commit state files, access keys, or secrets
- Prefer temporary credentials (AWS SSO) over long-lived access keys
- Restrict security group ingress to known CIDR ranges

## Cost Warning

NAT gateways and load balancers are billed hourly. Run `terraform destroy` on test environments when you're done.

## Roadmap

- [ ] Security module with dynamic ingress rules
- [ ] Compute module (launch template, ASG, ALB)
- [ ] `terraform test` for modules
- [ ] CI pipeline (fmt, validate, tflint, plan, manual approval for apply)

## Author

Nishad P — DevOps Engineer
[LinkedIn](https://linkedin.com/in/nishad-clt)
