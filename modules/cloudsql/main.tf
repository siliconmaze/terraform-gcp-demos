# =============================================================================
# Cloud SQL Module
# Production pattern: PostgreSQL/MySQL with HA, encryption, backups
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  labels      = merge(var.labels, {
    name = local.name_prefix
  })
}

# -----------------------------------------------------------------------------
# Service Account for Cloud SQL
# -----------------------------------------------------------------------------
resource "google_service_account" "cloudsql" {
  count = var.enable_public_ip ? 1 : 0
  
  project      = var.project_id
  account_id  = "${local.name_prefix}-cloudsql-sa"
  display_name = "Cloud SQL Service Account"
  description  = "Service account for Cloud SQL instance"
}

# -----------------------------------------------------------------------------
# Cloud SQL Instance
# -----------------------------------------------------------------------------
resource "google_sql_database_instance" "main" {
  name = var.instance_name
  project = var.project_id
  region = var.region
  
  database_version = var.database_version
  tier = var.tier
  
  # Availability
  availability_type = var.availability_type
  
  # Storage
  settings {
    tier = var.tier
    
    # Storage configuration
    storage {
      type = "PD_SSD"
      auto_resize_limit = "0"
      auto_resize = true
      data_disk_size_gb = var.disk_size
    }
    
    # Backup configuration
    backup_configuration {
      enabled = var.backup_enabled
      
      if var.backup_enabled {
        binary_log_enabled = var.database_version != "POSTGRES_15" ? false : true
        start_time = var.backup_start_time
        point_in_time_recovery_enabled = var.availability_type == "REGIONAL"
      }
    }
    
    # High availability
    if var.availability_type == "REGIONAL" {
      availability_type = "REGIONAL"
    }
    
    # IP Configuration
    ip_configuration {
      ipv4_enabled = var.enable_public_ip
      
      private_network = "projects/${var.project_id}/global/networks/${var.network_name}"
      
      # Authorize Google Cloud services
      enable_private_path_for_google_cloud_services = true
    }
    
    # Machine type (tier)
    machine_type = var.tier
    
    # Maintenance
    maintenance_window {
      day = var.maintenance_window.day
      hour = var.maintenance_window.hour
    }
    
    # Database flags
    database_flags = var.database_flags
    
    # Insights
    insights_config {
      query_insights_enabled = true
      query_string_length = 1024
      record_application_tags = true
      record_client_address = false
    }
    
    # User labels
    user_labels = local.labels
  }
  
  # Deletion protection
  deletion_protection = var.deletion_protection
  
  # Timeouts
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  
  labels = local.labels
  
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------
resource "google_sql_database" "main" {
  name = var.database_name
  project = var.project_id
  instance = google_sql_database_instance.main.name
  charset = var.database_charset
  collation = var.database_collation
  
  depends_on = [google_sql_database_instance.main]
}

# -----------------------------------------------------------------------------
# User
# -----------------------------------------------------------------------------
resource "google_sql_user" "main" {
  count = var.create_user ? 1 : 0
  
  name = var.username
  project = var.project_id
  instance = google_sql_database_instance.main.name
  password = var.password
  
  type = "BUILT_IN"
}

# -----------------------------------------------------------------------------
# Ssl Certificates (for private access)
# -----------------------------------------------------------------------------
resource "google_sql_ssl_cert" "main" {
  count = var.create_ssl_cert ? 1 : 0
  
  common_name = "client-cert"
  project = var.project_id
  instance = google_sql_database_instance.main.name
  
  depends_on = [google_sql_database_instance.main]
}
