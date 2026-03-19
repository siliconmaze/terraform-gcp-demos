# ==============================================================================
# Demo 3: GKE Cluster
# Objective: Create a managed Kubernetes cluster
# ==============================================================================

# 1. Create VPC Network
resource "google_compute_network" "this" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# 2. Create Subnet
resource "google_compute_subnetwork" "this" {
  name          = var.network_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}

# 3. Create GKE Cluster
resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region
  
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = google_compute_network.this.name
  subnetwork = google_compute_subnetwork.this.name
  
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }
  
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  }
  
  labels = {
    environment = var.environment
    demo       = "demo3"
  }
  
  timeouts {
    create = "30m"
    update = "30m"
  }
}

# 4. Create Node Pool
resource "google_container_node_pool" "this" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.this.name
  
  node_count = var.node_count
  
  node_config {
    machine_type = var.machine_type
    disk_size_gb = 20
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
    
    labels = {
      environment = var.environment
    }
    
    tags = ["demo-node"]
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
