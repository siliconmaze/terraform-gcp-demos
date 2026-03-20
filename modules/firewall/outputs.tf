output "rule_names" { value = concat(
  google_compute_firewall.allow_internal[*].name,
  google_compute_firewall.allow_ssh[*].name,
  [google_compute_firewall.allow_https.name, google_compute_firewall.allow_http.name, google_compute_firewall.allow_gke_nodes.name]
) }
output "allow_internal_name" { value = try(google_compute_firewall.allow_internal[0].name, "") }
output "allow_ssh_name" { value = try(google_compute_firewall.allow_ssh[0].name, "") }
