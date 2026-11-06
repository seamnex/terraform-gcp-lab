output "mig" {
  description = "Grupo de instancias de la app."
  value       = module.compute.mig
}

output "service_account" {
  description = "Service account de las VMs."
  value       = module.iam.email
}

output "red" {
  description = "VPC del entorno."
  value       = module.network.red_id
}
