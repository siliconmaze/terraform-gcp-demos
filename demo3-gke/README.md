# GCP Demo 3: GKE Cluster

**Objective:** Create a managed Kubernetes cluster.

## Prerequisites

### 1. Install Tools
```bash
brew install terraform
brew install google-cloud-sdk
brew install kubectl
```

### 2. Configure Authentication

**Local Development**
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

**Service Account**
```bash
export GOOGLE_APPLICATION_CREDENTIALS=./service-account-key.json
export GOOGLE_PROJECT=your-project-id
```

### 3. Enable APIs
```bash
gcloud services enable container.googleapis.com
```

## Step-by-Step

```bash
cd demo3-gke

# Update project_id in versions.tf first!
vim versions.tf  # Set your project_id

terraform init
terraform apply  # Takes ~10 minutes!

# Get credentials
gcloud container clusters get-credentials demo-cluster --region us-central1

kubectl get nodes

# Deploy app
kubectl create deployment demo-app --image=nginx
kubectl expose deployment demo-app --port=80 --type=LoadBalancer
kubectl get services

# Clean up
kubectl delete deployment demo-app
kubectl delete service demo-app
terraform destroy
```

## Cost Warning
⚠️ GKE is NOT free tier! ~$3-5/day. Destroy when done!

## Next Steps
🎉 Completed all GCP Terraform Demos!
