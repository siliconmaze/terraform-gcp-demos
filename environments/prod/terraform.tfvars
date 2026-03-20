# =============================================================================
# Production Environment Configuration - GCP
# =============================================================================

project_id     = "my-project-prod"
project_name   = "myapp"
environment    = "prod"
gcp_region     = "us-central1"
gcp_zone       = "us-central1-a"

# Network
network_cidr = "10.2.0.0/16"
subnet_cidrs = {
  primary   = "10.2.1.0/24"
  secondary = "10.2.2.0/24"
}

# GKE
gke_cluster_name          = "myapp-prod-cluster"
gke_num_nodes             = 3
gke_machine_type          = "e2-standard-2"
gke_enable_private_nodes = true
gke_enable_autoscaling   = true
gke_min_nodes             = 3
gke_max_nodes             = 10

# Cloud SQL
cloudsql_instance_name     = "myapp-prod-db"
cloudsql_tier             = "db-custom-2-4096"
cloudsql_disk_size        = 100
cloudsql_high_availability = true

# Security
enable_deletion_protection = true
