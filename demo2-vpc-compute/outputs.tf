output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.this.name
}

output "instance_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.this.name
}

output "external_ip" {
  description = "External IP of the instance"
  value       = google_compute_instance.this.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "gcloud compute ssh ${var.instance_name} --zone=${var.zone}"
}
