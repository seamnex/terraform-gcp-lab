output "mig" {
  description = "Nombre del grupo de instancias administrado."
  value       = google_compute_region_instance_group_manager.app.name
}

output "instance_group" {
  description = "URL del instance group, para conectarlo a un balanceador."
  value       = google_compute_region_instance_group_manager.app.instance_group
}
