output "bucket_state" {
  description = "Bucket para el backend de envs/dev y envs/prod."
  value       = google_storage_bucket.tfstate.name
}

output "wif_provider" {
  description = "Valor para la variable GCP_WIF_PROVIDER del repo en GitHub."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "ci_service_account" {
  description = "Valor para la variable GCP_SA_PLAN del repo en GitHub."
  value       = google_service_account.ci_plan.email
}
