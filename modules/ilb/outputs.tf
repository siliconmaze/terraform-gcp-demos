output "ip_address" { value = google_compute_address.internal.address }
output "forwarding_rule_name" { value = google_compute_forwarding_rule.main.name }
output "forwarding_rule_id" { value = google_compute_forwarding_rule.main.id }
output "backend_service_name" { value = google_compute_backend_service.main.name }
output "health_check_name" { value = google_compute_health_check.main.name }
