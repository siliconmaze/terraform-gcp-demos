output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = google_container_cluster.this.endpoint
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = google_container_cluster.this.location
}

output "kubectl_command" {
  description = "Command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region}"
}

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.this.name
}
