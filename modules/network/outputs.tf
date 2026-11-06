output "red_id" {
  description = "ID de la VPC."
  value       = google_compute_network.vpc.id
}

output "subred_id" {
  description = "ID de la subred principal."
  value       = google_compute_subnetwork.principal.id
}
