# =============================================================================
# GKE Module - Google Kubernetes Engine
# Production pattern: Private cluster, autoscaling, security hardening
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  labels      = merge(var.labels, {
    name = local.name_prefix
  })
}

# -----------------------------------------------------------------------------
# Service Account for GKE Nodes
# -----------------------------------------------------------------------------
resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id  = "${local.name_prefix}-gke-sa"
  display_name = "GKE Node Service Account"
  description = "Service account for GKE nodes"
}

# IAM roles for node service account
resource "google_project_iam_member" "gke_nodes_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# -----------------------------------------------------------------------------
# GKE Cluster
# -----------------------------------------------------------------------------
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.location
  
  # Network configuration
  network    = var.network_name
  subnetwork = var.subnet_name
  
  # Release channel
  release_channel {
    channel = var.environment == "prod" ? "STABLE" : "REGULAR"
  }
  
  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block = var.master_cidr
  }
  
  # Master authorized networks (for accessing control plane)
  dynamic "master_authorized_networks_config" {
    for_each = var.allowed_master_cidrs != [] ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.allowed_master_cidrs
        content {
          cidr_block   = cidr_blocks.value
          display_name = "Admin Network"
        }
      }
    }
  }
  
  # IP allocation for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }
  
  # Node pool configuration
  node_pool {
    name = "default-pool"
    
    initial_node_count = var.num_nodes
    
    node_config {
      machine_type    = var.machine_type
      service_account = google_service_account.gke_nodes.email
      
      # Disk configuration
      disk_type    = "pd-ssd"
      disk_size_gb = var.disk_size_gb
      
      # Shielded nodes (production)
      shielded_instance_config {
        enable_secure_boot          = var.enable_shielded_nodes
        enable_integrity_monitoring = var.enable_shielded_nodes
      }
      
      # Labels for nodes
      labels = merge(local.labels, {
        "node-pool" = "default"
      })
      
      # Tags
      tags = ["gke-node"]
    }
    
    # Autoscaling
    autoscaling {
      min_node_count = var.enable_autoscaling ? var.min_nodes : null
      max_node_count = var.enable_autoscaling ? var.max_nodes : null
    }
    
    # Management
    management {
      auto_repair  = true
      auto_upgrade = true
    }
    
    # Upgrade settings
    upgrade_settings {
      max_surge       = 1
      max_unavailable = 0
    }
  }
  
  # Maintenance window
  maintenance_policy {
    dynamic "window" {
      for_each = var.maintenance_window != {} ? [1] : []
      content {
        daily_maintenance_window {
          start_time = var.maintenance_window.start
          end_time   = var.maintenance_window.end
        }
        
        recurring_window {
          start_time = "${var.maintenance_window.day} ${var.maintenance_window.start}"
          end_time   = "${var.maintenance_window.day} ${var.maintenance_window.end}"
          recurrence = "FREQ=WEEKLY"
        }
      }
    }
  }
  
  # Network Policy (production)
  network_policy {
    enabled = var.enable_network_policy
  }
  
  # Pod security policy (use RBAC instead)
  # pod_security_policy_config {
  #   enabled = true
  # }
  
  # Vertical Pod Autoscaling
  vertical_pod_autoscaling {
    enabled = var.enable_vpa
  }
  
  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Cloud Operations
  enable_legacy_abac = false
  
  # Logging
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = !var.enable_network_policy
    }
    gcp_filestore_csi_driver {
      enabled = false
    }
    gce_persistent_disk_csi_driver {
      enabled = true
    }
    cloudrun_config {
      disabled = true
    }
  }
  
  # Resource labels
  resource_labels = local.labels
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [node_pool]
  }
}

# -----------------------------------------------------------------------------
# Node Pool (for production - separate from default)
# -----------------------------------------------------------------------------
resource "google_container_node_pool" "secondary" {
  count = var.create_secondary_node_pool ? 1 : 0
  
  name     = "${var.cluster_name}-secondary"
  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.primary.name
  
  node_count = var.secondary_node_count
  
  node_config {
    machine_type = var.secondary_machine_type
    
    disk_type    = "pd-ssd"
    disk_size_gb = var.secondary_disk_size
    
    service_account = google_service_account.gke_nodes.email
    
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    
    labels = merge(local.labels, {
      "node-pool" = "compute-intensive"
    })
    
    taint {
      key    = "workload"
      value  = "compute-intensive"
      effect = "NO_SCHEDULE"
    }
  }
  
  autoscaling {
    min_node_count = var.secondary_min_nodes
    max_node_count = var.secondary_max_nodes
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
