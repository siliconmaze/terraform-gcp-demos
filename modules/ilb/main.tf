# =============================================================================
# Internal Load Balancer Module - GCP
# Production pattern: Regional ILB with health checks
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  labels      = merge(var.labels, {
    name = local.name_prefix
  })
}

# -----------------------------------------------------------------------------
# Reserve Static IP
# -----------------------------------------------------------------------------
resource "google_compute_address" "internal" {
  name = var.name
  project = var.project_id
  region = var.region
  subnetwork = var.subnet_name
  address_type = "INTERNAL"
  purpose = "GCE_ENDPOINT"
  
  labels = local.labels
}

# -----------------------------------------------------------------------------
# Health Check
# -----------------------------------------------------------------------------
resource "google_compute_health_check" "main" {
  name = "${var.name}-health-check"
  project = var.project_id
  
  http_health_check {
    port = var.health_check_port
    request_path = var.health_check_path
    response = var.health_check_response
  }
  
  check_interval_sec = var.health_check_interval
  timeout_sec = var.health_check_timeout
  healthy_threshold = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold
  
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Backend Service
# -----------------------------------------------------------------------------
resource "google_compute_backend_service" "main" {
  name = "${var.name}-backend"
  project = var.project_id
  protocol = "HTTP"
  port_name = "http"
  
  health_checks = [google_compute_health_check.main.id]
  
  backend {
    group = var.instance_group
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
  
  load_balancing_scheme = "INTERNAL"
  
  lifecycle {
    create_before_destroy = true
  }
  
  labels = local.labels
}

# -----------------------------------------------------------------------------
# Forwarding Rule
# -----------------------------------------------------------------------------
resource "google_compute_forwarding_rule" "main" {
  name = "${var.name}-forwarding"
  project = var.project_id
  region = var.region
  
  load_balancing_scheme = "INTERNAL"
  backend_service = google_compute_backend_service.main.id
  
  ip_address = google_compute_address.internal.address
  ip_protocol = "TCP"
  ports = [var.backend_port]
  
  network = var.network_name
  subnetwork = var.subnet_name
  
  labels = local.labels
}
