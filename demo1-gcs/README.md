# GCP Demo 1: Cloud Storage Bucket

**Objective:** Create a simple Cloud Storage bucket.

## Prerequisites

### 1. Install Tools

```bash
brew install terraform
brew install google-cloud-sdk
```

### 2. Configure GCP Authentication

**Option A: gcloud CLI (Recommended for local dev)**

```bash
# Authenticate with your Google account
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Verify
gcloud auth list
gcloud config get-value project
```

**Option B: Service Account (Recommended for CI/CD)**

```bash
# Create a service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Download key
gcloud iam service-accounts keys create terraform-key.json \
    --iam-account=terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=./terraform-key.json
```

**Option C: Using a Service Account Key File**

```bash
# Export the key file path
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service-account-key.json

# Or set in Terraform
export GOOGLE_PROJECT=your-project-id
```

### 3. Enable Required APIs

```bash
gcloud services enable storage.googleapis.com container.googleapis.com compute.googleapis.com
```

## Step-by-Step

### Step 1: Update Variables

Edit `variables.tf` and set your project ID:

```hcl
variable "project_id" {
  default = "your-actual-project-id"  # CHANGE THIS!
}
```

### Step 2: Initialize Terraform

```bash
cd demo1-gcs
terraform init
```

### Step 3: Apply

```bash
terraform plan
terraform apply
```

### Step 4: Test

```bash
echo "Hello!" > test.txt
gsutil cp test.txt gs://your-bucket-name/
gsutil ls gs://your-bucket-name/
```

### Step 5: Destroy

```bash
terraform destroy
```

## Authentication Reference

| Method | Best For | Command |
|--------|----------|---------|
| `gcloud auth adc` | Local development | `gcloud auth application-default login` |
| Service Account | CI/CD, production | Set `GOOGLE_APPLICATION_CREDENTIALS` |
| JSON Key File | Manual deployment | Export key path |

## Next Steps
➡️ [Demo 2: VPC + Compute Engine](../demo2-vpc-compute/README.md)
