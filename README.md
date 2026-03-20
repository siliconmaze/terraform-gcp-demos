# GCP Terraform Demos & Production Infrastructure

A comprehensive collection of Terraform configurations for Google Cloud Platform, ranging from beginner-friendly demos to production-ready infrastructure patterns.

## Repository Structure

```
terraform-gcp-demos/
├── README.md                     # This file
├── demo1-gcs/                     # Demo 1: Cloud Storage Bucket (⭐)
├── demo2-vpc-compute/             # Demo 2: VPC + Compute Engine (⭐⭐)
├── demo3-gke/                     # Demo 3: GKE Cluster (⭐⭐⭐)
├── modules/                       # Production-ready reusable modules
│   ├── vpc/                       # VPC, subnets, Cloud NAT, DNS
│   ├── gke/                       # GKE cluster, node pools
│   ├── cloudsql/                  # Cloud SQL PostgreSQL/MySQL
│   ├── ilb/                       # Internal Load Balancer
│   ├── firewall/                 # Firewall rules
│   └── iam/                       # Workload Identity, service accounts
├── environments/                  # Environment-specific variables
│   ├── dev/
│   ├── staging/
│   └── prod/
├── scripts/                       # Utility scripts
│   └── workspace.sh               # Terraform workspace management
├── backend.tf.example             # GCS backend configuration template
├── versions.tf                    # Terraform & provider version constraints
├── main.tf                        # Root module (production infrastructure)
├── variables.tf                   # Root variables with validation
└── outputs.tf                     # Root outputs
```

## Quick Start: Try a Demo

```bash
# Install tools
brew install terraform
brew install google-cloud-sdk

# Authenticate
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID

# Run a demo
cd demo1-gcs
terraform init
terraform plan
terraform apply
terraform destroy
```

## Demo Directory

| Demo | Description | Complexity | Cost | Time |
|------|-------------|------------|------|------|
| [demo1-gcs](demo1-gcs/README.md) | Cloud Storage Bucket | ⭐ | Free | 5 min |
| [demo2-vpc-compute](demo2-vpc-compute/README.md) | VPC + Compute Engine | ⭐⭐ | Free tier | 10 min |
| [demo3-gke](demo3-gke/README.md) | GKE Cluster | ⭐⭐⭐ | ~$3-5/day | 15 min |

## Production Infrastructure

The `main.tf` orchestrates a complete production-grade GCP infrastructure:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              GCP VPC Network                                 │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     Primary Subnet (10.0.1.0/24)                    │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    GKE Private Cluster                        │   │   │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │   │   │
│  │  │  │  Node   │  │  Node   │  │  Node   │  │  Node   │         │   │   │
│  │  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘         │   │   │
│  │  │       │            │            │            │              │   │   │
│  │  │       └────────────┴────────────┴────────────┘              │   │   │
│  │  │                    │                                        │   │   │
│  │  │              ┌─────┴─────┐                                  │   │   │
│  │  │              │ Internal  │                                  │   │   │
│  │  │              │  LB      │                                  │   │   │
│  │  │              └───────────┘                                  │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                   Secondary Subnet (10.0.2.0/24)                   │   │
│  │                                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │              Cloud SQL (PostgreSQL/MySQL)                    │   │   │
│  │  │           Primary    │    Replica    │    Replica            │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         Cloud NAT Gateway                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Production Features

| Feature | Description |
|---------|-------------|
| **Private GKE** | Nodes without public IPs, private cluster |
| **Workload Identity** | Secure GCP access without static credentials |
| **Cloud SQL HA** | Regional availability with automated backups |
| **Network Policy** | Kubernetes network policies enforced |
| **Shielded Nodes** | Enhanced node security (prod) |
| **VPA** | Vertical Pod Autoscaling enabled |
| **Cluster Autoscaling** | Automatic node scaling |

### Production Deployment

```bash
# 1. Copy and configure backend
cp backend.tf.example backend.tf
# Edit backend.tf with your GCS bucket name

# 2. Initialize with workspace
./scripts/workspace.sh create dev
./scripts/workspace.sh select dev

# 3. Customize environment variables
vi environments/dev/terraform.tfvars

# 4. Deploy
terraform init
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Reusable Modules

### VPC Module (`modules/vpc`)
```hcl
module "vpc" {
  source  = "./modules/vpc"
  project = var.project_id
  name    = "my-vpc"
  region  = "us-central1"
}
```

### GKE Module (`modules/gke`)
```hcl
module "gke" {
  source           = "./modules/gke"
  project_id       = var.project_id
  name             = "my-cluster"
  location         = var.region
  vpc_self_link    = module.vpc.self_link
  subnet_self_link = module.vpc.subnets_secondary_ranges[0].self_link
}
```

### Cloud SQL Module (`modules/cloudsql`)
```hcl
module "cloudsql" {
  source        = "./modules/cloudsql"
  name          = "my-db"
  database_version = "POSTGRES_15"
  region        = var.region
  tier          = "db-n1-standard-2"
  network       = module.vpc.self_link
}
```

## Authentication Setup

### Option 1: gcloud CLI (Recommended for local)

```bash
# Install Google Cloud SDK
brew install google-cloud-sdk

# Authenticate with your Google account
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Verify
gcloud auth list
gcloud config get-value project
```

### Option 2: Service Account (Recommended for CI/CD)

```bash
# Create a service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account"

# Grant roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/container.admin"

# Download key
gcloud iam service-accounts keys create terraform-key.json \
    --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=./terraform-key.json
```

## Enable Required APIs

```bash
gcloud services enable \
  storage.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  sqladmin.googleapis.com \
  dns.googleapis.com
```

## Workspace Management

Manage Terraform workspaces with the included script:

```bash
# List all workspaces
./scripts/workspace.sh list

# Show current workspace
./scripts/workspace.sh show

# Create a new workspace
./scripts/workspace.sh create staging

# Switch to a workspace
./scripts/workspace.sh select dev

# Delete a workspace (requires confirmation)
./scripts/workspace.sh delete old-env
```

## License

MIT License - See individual demo READMEs for details.
