output "cluster_name" { value = google_container_cluster.primary.name }
output "cluster_id" { value = google_container_cluster.primary.id }
output "cluster_self_link" { value = google_container_cluster.primary.self_link }
output "endpoint" { value = google_container_cluster.primary.endpoint }
output "master_version" { value = google_container_cluster.primary.master_version }
output "node_version" { value = google_container_cluster.primary.node_version }

output "service_account_email" { value = google_service_account.gke_nodes.email }
output "service_account" { value = google_service_account.gke_nodes }

output "kubeconfig" {
  value = templatefile("${path.module}/templates/kubeconfig.tftpl", {
    cluster_name = google_container_cluster.primary.name
    endpoint     = google_container_cluster.primary.endpoint
    project_id   = var.project_id
    location     = var.location
  })
  sensitive = true
}

output "node_pool_name" { value = google_container_cluster.primary.node_pool[0].name }
output "node_pool_id" { value = google_container_cluster.primary.node_pool[0].id }
