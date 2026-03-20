# =============================================================================
# Staging Environment Configuration - GCP
# =============================================================================

project_id     = "my-project-staging"
project_name   = "myapp"
environment    = "staging"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# Network
network_cidr = "10.1.0.0/16"
subnet_cidrs = {
  primary   = "10.1.1.0/24"
  secondary = "10.1.2.0/24"
}

# GKE
gke_cluster_name          = "myapp-staging-cluster"
gke_num_nodes             = 2
gke_machine_type          = "e2-medium"
gke_enable_private_nodes = true

# Cloud SQL
cloudsql_instance_name   = "myapp-staging-db"
cloudsql_tier           = "db-e2-medium"
cloudsql_disk_size      = 50
cloudsql_high_availability = false

# Security
enable_deletion_protection = false
