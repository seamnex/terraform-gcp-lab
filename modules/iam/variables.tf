variable "project_id" {
  description = "Proyecto de GCP."
  type        = string
}

variable "nombre" {
  description = "Prefijo de la service account (máximo 27 caracteres para dejar lugar a \"-vm\")."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,26}$", var.nombre))
    error_message = "nombre: minúsculas, números y guiones, entre 5 y 27 caracteres, empezando con letra."
  }
}

variable "roles" {
  description = "Roles de proyecto de la service account de las VMs."
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]

  # Guardarraíl: estos roles no se le dan a una VM, ni por error en un tfvars.
  validation {
    condition = length(setintersection(var.roles, [
      "roles/owner", "roles/editor", "roles/iam.securityAdmin", "roles/iam.serviceAccountTokenCreator",
    ])) == 0
    error_message = "La service account de las VMs no puede tener owner, editor ni roles para emitir credenciales."
  }
}
