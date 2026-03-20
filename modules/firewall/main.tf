# =============================================================================
# Firewall Module - GCP
# Production pattern: Allow internal, restrict SSH
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  labels      = merge(var.labels, {
    name = local.name_prefix
  })
}

# Allow internal traffic (all protocols)
resource "google_compute_firewall" "allow_internal" {
  count = var.allow_internal ? 1 : 0
  
  name = "${local.name_prefix}-allow-internal"
  project = var.project_id
  network = var.network_name
  
  direction = "INGRESS"
  priority = 65534
  
  source_ranges = ["10.0.0.0/8"]
  
  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["allow-internal"]
  
  labels = local.labels
}

# Allow SSH from specific CIDRs
resource "google_compute_firewall" "allow_ssh" {
  count = length(var.allowed_ssh_cidrs) > 0 ? 1 : 0
  
  name = "${local.name_prefix}-allow-ssh"
  project = var.project_id
  network = var.network_name
  
  direction = "INGRESS"
  priority = 65532
  
  source_ranges = var.allowed_ssh_cidrs
  
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  
  target_tags = ["allow-ssh"]
  
  labels = local.labels
}

# Allow HTTPS
resource "google_compute_firewall" "allow_https" {
  name = "${local.name_prefix}-allow-https"
  project = var.project_id
  network = var.network_name
  
  direction = "INGRESS"
  priority = 65530
  
  source_ranges = ["0.0.0.0/0"]
  
  allow {
    protocol = "tcp"
    ports = ["443"]
  }
  
  target_tags = ["allow-https"]
  
  labels = local.labels
}

# Allow HTTP
resource "google_compute_firewall" "allow_http" {
  name = "${local.name_prefix}-allow-http"
  project = var.project_id
  network = var.network_name
  
  direction = "INGRESS"
  priority = 65531
  
  source_ranges = ["0.0.0.0/0"]
  
  allow {
    protocol = "tcp"
    ports = ["80"]
  }
  
  target_tags = ["allow-http"]
  
  labels = local.labels
}

# Allow GKE nodes communication
resource "google_compute_firewall" "allow_gke_nodes" {
  name = "${local.name_prefix}-allow-gke-nodes"
  project = var.project_id
  network = var.network_name
  
  direction = "INGRESS"
  priority = 1000
  
  source_tags = ["gke-node"]
  
  allow {
    protocol = "tcp"
    ports = ["10250", "10255", "30000-32767"]
  }
  
  allow {
    protocol = "udp"
    ports = ["30000-32767"]
  }
  
  labels = local.labels
}
