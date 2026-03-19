# GCP Terraform Demos

Simple, step-by-step Terraform demos for Google Cloud Platform.

## Demos

### Demo 1: Cloud Storage Bucket
**Objective:** Create a simple Cloud Storage bucket.

📖 [Read the Guide](demo1-gcs/README.md)

```bash
cd demo1-gcs
terraform init
terraform plan
terraform apply
```

---

### Demo 2: VPC + Compute Engine
**Objective:** Create a VPC with a virtual machine.

📖 [Read the Guide](demo2-vpc-compute/README.md)

```bash
cd demo2-vpc-compute
terraform init
terraform apply
gcloud compute ssh demo-instance --zone=us-central1-a
```

---

### Demo 3: GKE Cluster
**Objective:** Create a managed Kubernetes cluster.

📖 [Read the Guide](demo3-gke/README.md)

```bash
cd demo3-gke
terraform init
terraform apply  # Takes ~10 minutes!
gcloud container clusters get-credentials demo-cluster --region us-central1
```

---

## Quick Reference

| Demo | Service | Complexity | Cost |
|------|---------|------------|------|
| 1 | Cloud Storage | ⭐ | Free |
| 2 | VPC + Compute | ⭐⭐ | Free tier |
| 3 | GKE | ⭐⭐⭐ | ~$3-5/day |

## Prerequisites

```bash
# Install Terraform
brew install terraform

# Install Google Cloud SDK
brew install google-cloud-sdk

# Authenticate
gcloud auth application-default login
```

## Cleanup

Always destroy resources when done:
```bash
terraform destroy
```
