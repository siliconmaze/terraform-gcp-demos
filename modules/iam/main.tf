# =============================================================================
# IAM Module - GCP
# Production pattern: Workload Identity, service accounts
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  labels      = merge(var.labels, {
    name = local.name_prefix
  })
}

# Kubernetes Service Account
resource "google_service_account" "k8s" {
  count = var.enable_workload_identity ? 1 : 0
  
  project = var.project_id
  account_id = "${local.name_prefix}-k8s-sa"
  display_name = "Kubernetes Service Account"
  description = "KSA for workload identity"
}

# IAM Policy Bindings for GCP Service Account
resource "google_project_iam_member" "gcp_roles" {
  count = var.enable_workload_identity ? length(var.iam_roles) : 0
  
  project = var.project_id
  role = var.iam_roles[count.index]
  member = "serviceAccount:${google_service_account.k8s[0].email}"
}

# Workload Identity Pool (optional - if not using default)
resource "google_iam_workload_identity_pool" "main" {
  count = var.enable_workload_identity ? 1 : 0
  
  project = var.project_id
  
  workload_identity_pool_id = "${var.project_name}-${var.environment}-pool"
  
  display_name = "Workload Identity Pool"
  description = "Workload Identity Pool for ${var.project_name}"
  
  disabled = false
}

resource "google_iam_workload_identity_pool_provider" "main" {
  count = var.enable_workload_identity ? 1 : 0
  
  project = var.project_id
  workload_identity_pool_id = google_iam_workload_identity_pool.main[0].workload_identity_pool_id
  
  workload_identity_pool_provider_id = "github-provider"
  
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
