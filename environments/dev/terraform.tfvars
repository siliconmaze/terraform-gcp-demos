# =============================================================================
# Development Environment Configuration - GCP
# =============================================================================

project_id     = "my-project-dev"
project_name   = "myapp"
environment    = "dev"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# Network
network_cidr = "10.0.0.0/16"
subnet_cidrs = {
  primary   = "10.0.1.0/24"
  secondary = "10.0.2.0/24"
}

# GKE
gke_cluster_name          = "myapp-dev-cluster"
gke_num_nodes             = 1
gke_machine_type          = "e2-small"
gke_enable_private_nodes = false

# Cloud SQL
cloudsql_instance_name   = "myapp-dev-db"
cloudsql_tier           = "db-f1-micro"
cloudsql_disk_size      = 20
cloudsql_high_availability = false

# Security
enable_deletion_protection = false
