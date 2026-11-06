variable "project_id" {
  description = "Proyecto donde viven el bucket de state y el pool de WIF (puede ser el de dev o uno de administración)."
  type        = string
}

variable "bucket_state" {
  description = "Nombre del bucket de state. Global en todo GCS: tiene que ser único en el mundo."
  type        = string
}

variable "ubicacion" {
  description = "Ubicación del bucket."
  type        = string
  default     = "US-CENTRAL1"
}

variable "repo_github" {
  description = "Único repo autorizado a usar el pool de WIF, en formato owner/repo."
  type        = string
  default     = "seamnex/terraform-gcp-lab"
}

variable "proyectos_a_planear" {
  description = "Proyectos que el CI puede leer para correr plan (dev y prod)."
  type        = list(string)
}
