# GCP Demo 2: VPC + Compute Engine

**Objective:** Create a VPC with a virtual machine.

## Prerequisites

### 1. Install Tools
```bash
brew install terraform
brew install google-cloud-sdk
```

### 2. Configure Authentication

**Local Development (Recommended)**
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

**Service Account (CI/CD)**
```bash
export GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
export GOOGLE_PROJECT=your-project-id
```

### 3. Enable APIs
```bash
gcloud services enable compute.googleapis.com
```

## Step-by-Step

```bash
cd demo2-vpc-compute

# Update project_id in versions.tf first!
vim versions.tf  # Set your project_id

terraform init
terraform plan
terraform apply

# Get IP
terraform output

# Connect
gcloud compute ssh demo-instance --zone=us-central1-a

terraform destroy
```

## Files
| File | Purpose |
|------|---------|
| main.tf | VPC, Subnet, Firewall, Instance |
| variables.tf | Configurable options |
| outputs.tf | Shows IP after creation |

## Next Steps
➡️ [Demo 3: GKE Cluster](../demo3-gke/README.md)
