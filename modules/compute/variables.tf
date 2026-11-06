variable "project_id" {
  description = "Proyecto de GCP."
  type        = string
}

variable "nombre" {
  description = "Prefijo de los recursos."
  type        = string
}

variable "region" {
  description = "Región del MIG."
  type        = string
}

variable "zonas" {
  description = "Zonas donde el MIG reparte las instancias. Una en dev; dos o más en prod."
  type        = list(string)

  validation {
    condition     = length(var.zonas) > 0
    error_message = "Hace falta al menos una zona."
  }
}

variable "subred_id" {
  description = "Subred donde se conectan las VMs."
  type        = string
}

variable "service_account_email" {
  description = "Service account con la que corren las VMs."
  type        = string
}

variable "tag_app" {
  description = "Network tag que las reglas de firewall usan como destino."
  type        = string
}

variable "tipo_maquina" {
  description = "Tipo de máquina de las VMs."
  type        = string
}

variable "tipo_disco" {
  description = "Tipo del disco de arranque. pd-standard entra en el free tier; pd-balanced es más rápido."
  type        = string
  default     = "pd-balanced"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd"], var.tipo_disco)
    error_message = "tipo_disco tiene que ser pd-standard, pd-balanced o pd-ssd."
  }
}

variable "replicas" {
  description = "Cantidad de instancias del MIG."
  type        = number

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "replicas tiene que estar entre 1 y 10 (techo de laboratorio para no generar costos por error)."
  }
}

variable "spot" {
  description = "Usar VMs Spot: más baratas, pero GCP puede reclamarlas en cualquier momento."
  type        = bool
  default     = false
}

variable "imagen" {
  description = "Imagen de contenedor que corre en cada VM."
  type        = string
}

variable "puerto_app" {
  description = "Puerto expuesto por la VM para la app."
  type        = number
}

variable "gracia_autohealing_seg" {
  description = "Segundos de gracia antes de que el autohealing evalúe una VM nueva."
  type        = number
  default     = 180
}

variable "etiquetas" {
  description = "Labels de GCP para costos y búsqueda."
  type        = map(string)
  default     = {}
}
