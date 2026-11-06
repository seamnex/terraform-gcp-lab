terraform {
  required_version = ">= 1.9"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  # Todo recurso creado lleva estas labels: es lo que permite filtrar la
  # factura por entorno y encontrar qué creó Terraform y qué no.
  default_labels = {
    entorno    = var.entorno
    gestionado = "terraform"
    repo       = "terraform-gcp-lab"
  }
}
