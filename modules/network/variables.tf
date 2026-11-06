variable "project_id" {
  description = "Proyecto de GCP donde se crea la red."
  type        = string
}

variable "nombre" {
  description = "Prefijo de los recursos (por ejemplo, lab-dev)."
  type        = string
}

variable "region" {
  description = "Región de la subred, el router y el NAT."
  type        = string
}

variable "cidr" {
  description = "Rango IPv4 de la subred principal."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "cidr tiene que ser un rango IPv4 válido, por ejemplo 10.10.0.0/24."
  }
}

variable "tag_app" {
  description = "Network tag de las VMs a las que aplican las reglas de firewall."
  type        = string
}

variable "puerto_app" {
  description = "Puerto donde escucha la app; lo usan los health checks."
  type        = number
}

variable "flow_logs" {
  description = "Muestreo (0 a 1) e intervalo de agregación de los VPC flow logs."
  type = object({
    muestreo  = number
    intervalo = string
  })

  validation {
    condition     = var.flow_logs.muestreo > 0 && var.flow_logs.muestreo <= 1
    error_message = "flow_logs.muestreo tiene que estar entre 0 (excluido) y 1."
  }
}
