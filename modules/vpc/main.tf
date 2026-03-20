# =============================================================================
# VPC Module - GCP
# Production pattern: Custom mode VPC with subnets, Cloud NAT, DNS
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  labels      = merge(var.labels, {
    name = local.name_prefix
  })
}

# -----------------------------------------------------------------------------
# VPC Network
# -----------------------------------------------------------------------------
resource "google_compute_network" "main" {
  name                    = local.name_prefix
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode           = var.routing_mode
  description             = "VPC network for ${var.project_name} ${var.environment}"
  
  lifecycle {
    prevent_destroy = false  # Allow destroy for cleanups
  }
  
  labels = local.labels
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------
resource "google_compute_subnetwork" "primary" {
  name          = "${local.name_prefix}-primary"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.main.name
  ip_cidr_range = var.subnet_cidrs["primary"]
  
  private_ip_google_access = var.enable_private_google_access
  
  # Stack type for IPv6 (optional)
  stack_type = "IPV4_ONLY"
  
  # Flow logs
  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "include_all_metadata"
    }
  }
  
  purpose = "PRIVATE_RFC_1918"
  
  labels = local.labels
}

resource "google_compute_subnetwork" "secondary" {
  name          = "${local.name_prefix}-secondary"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.main.name
  ip_cidr_range = var.subnet_cidrs["secondary"]
  
  private_ip_google_access = var.enable_private_google_access
  
  # Secondary ranges for pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
  
  stack_type = "IPV4_ONLY"
  
  labels = local.labels
}

# -----------------------------------------------------------------------------
# Cloud Router
# -----------------------------------------------------------------------------
resource "google_compute_router" "main" {
  name    = "${local.name_prefix}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.main.name
  
  bgp {
    asn = 64501
  }
  
  labels = local.labels
}

# -----------------------------------------------------------------------------
# Cloud NAT
# -----------------------------------------------------------------------------
resource "google_compute_router_nat" "main" {
  name                               = "${local.name_prefix}-nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.main.name
  nat_ip_allocation_option           = "AUTO_ONLY"
  
  source_active_fallback             = true
  
  # Allow all subnets to use NAT
  enable_endpoint_independent_mapping = true
  
  # Connection limits
  min_ports_per_vm              = 256
  max_ports_per_vm              = 65536
  
  # Log configuration
  log_config {
    filter = "ERRORS_ONLY"
  }
  
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  labels = local.labels
}

# -----------------------------------------------------------------------------
# Cloud DNS (Private Zone)
# -----------------------------------------------------------------------------
resource "google_dns_zone" "private" {
  count = var.enable_cloud_dns ? 1 : 0
  
  name        = var.dns_zone_name
  project     = var.project_id
  dns_name    = "${var.environment}.${var.project_name}.internal."
  description = "Private DNS zone for ${var.project_name}"
  
  visibility = "private"
  
  labels = local.labels
}

resource "google_dns_record_set" "api" {
  count = var.enable_cloud_dns ? 1 : 0
  
  name = "api.${google_dns_zone.private[0].dns_name}"
  type = "A"
  zone = google_dns_zone.private[0].name
  
  rrdatas = [google_compute_subnetwork.primary.ip_cidr_range]
  
  project = var.project_id
  
  labels = local.labels
}
