output "k8s_service_account_email" { value = try(google_service_account.k8s[0].email, "") }
output "workload_identity_pool_id" { value = try(google_iam_workload_identity_pool.main[0].workload_identity_pool_id, "") }
output "workload_identity_provider_id" { value = try(google_iam_workload_identity_pool_provider.main[0].workload_identity_pool_provider_id, "") }
