# ==============================================================================
# Demo 2: VPC + Compute Engine
# Objective: Create a VPC with a Compute Engine instance
# ==============================================================================

# 1. Create VPC Network
resource "google_compute_network" "this" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode           = "REGIONAL"
  
  labels = {
    environment = var.environment
    demo        = "demo2"
  }
}

# 2. Create Subnet
resource "google_compute_subnetwork" "this" {
  name          = var.network_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
  
  labels = {
    environment = var.environment
  }
}

# 3. Create Firewall Rule (allow SSH)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.this.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# 4. Create Firewall Rule (allow HTTP)
resource "google_compute_firewall" "allow_http" {
  name    = "${var.network_name}-allow-http"
  network = google_compute_network.this.name
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-http"]
}

# 5. Create Compute Engine Instance
resource "google_compute_instance" "this" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.this.name
    access_config {
      // Ephemeral external IP
    }
  }
  
  tags = ["allow-ssh", "allow-http"]
  
  metadata = {
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y apache2
      echo "<h1>Hello from Terraform Demo 2 (GCP)!</h1>" > /var/www/html/index.html
      EOF
  }
  
  labels = {
    environment = var.environment
  }
}
