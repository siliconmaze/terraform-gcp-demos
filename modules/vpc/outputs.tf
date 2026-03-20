output "network_name" { value = google_compute_network.main.name }
output "network_id" { value = google_compute_network.main.id }
output "network_self_link" { value = google_compute_network.main.self_link }
output "subnet_names" { value = { primary = google_compute_subnetwork.primary.name, secondary = google_compute_subnetwork.secondary.name } }
output "subnet_ips" { value = { primary = google_compute_subnetwork.primary.ip_cidr_range, secondary = google_compute_subnetwork.secondary.ip_cidr_range } }
output "subnet_self_links" { value = { primary = google_compute_subnetwork.primary.self_link, secondary = google_compute_subnetwork.secondary.self_link } }
output "secondary_ip_ranges" { value = { for range in google_compute_subnetwork.secondary.secondary_ip_range : range.range_name => range.ip_cidr_range } }
output "router_name" { value = google_compute_router.main.name }
output "nat_name" { value = google_compute_router_nat.main.name }
output "dns_zone_name" { value = try(google_dns_zone.private[0].name, null) }
output "dns_zone_dns_name" { value = try(google_dns_zone.private[0].dns_name, null) }
