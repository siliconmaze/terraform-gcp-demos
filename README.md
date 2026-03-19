# GCP Terraform Demos

Simple, step-by-step Terraform demos for Google Cloud Platform.

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

### Enable Required APIs

```bash
gcloud services enable storage.googleapis.com compute.googleapis.com container.googleapis.com
```

## Demos

| Demo | Description | Complexity | Cost |
|------|-------------|------------|------|
| [demo1-gcs](demo1-gcs/README.md) | Cloud Storage Bucket | ⭐ | Free |
| [demo2-vpc-compute](demo2-vpc-compute/README.md) | VPC + Compute | ⭐⭐ | Free tier |
| [demo3-gke](demo3-gke/README.md) | GKE Cluster | ⭐⭐⭐ | ~$3-5/day |

## Quick Start

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
terraform apply
terraform destroy
```
