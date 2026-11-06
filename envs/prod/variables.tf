variable "project_id" {
  description = "Proyecto de GCP del entorno. Uno por entorno: dev y prod no comparten proyecto."
  type        = string
}

variable "entorno" {
  description = "Nombre del entorno."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.entorno)
    error_message = "entorno tiene que ser dev o prod."
  }
}

variable "region" {
  description = "Región principal."
  type        = string
}

variable "zonas" {
  description = "Zonas del MIG."
  type        = list(string)
}

variable "cidr" {
  description = "Rango de la subred principal."
  type        = string
}

variable "tipo_maquina" {
  description = "Tipo de máquina de las VMs."
  type        = string
}

variable "tipo_disco" {
  description = "Tipo del disco de arranque."
  type        = string
}

variable "replicas" {
  description = "Cantidad de VMs."
  type        = number
}

variable "spot" {
  description = "Usar VMs Spot."
  type        = bool
}

variable "imagen" {
  description = "Imagen de contenedor de la app."
  type        = string
}

variable "puerto_app" {
  description = "Puerto de la app en la VM."
  type        = number
  default     = 8080
}

variable "flow_logs" {
  description = "Configuración de los VPC flow logs."
  type = object({
    muestreo  = number
    intervalo = string
  })
}
