# Bootstrap: lo que tiene que existir antes que todo lo demás.
#
#   1. El bucket donde vive el state remoto de dev y prod.
#   2. Workload Identity Federation para que GitHub Actions entre a GCP sin
#      una clave JSON: el runner presenta un token OIDC firmado por GitHub y
#      GCP lo cambia por credenciales de corta duración.
#
# Se aplica UNA vez, a mano, con tu propia cuenta (gcloud auth
# application-default login). Su state queda local a propósito: el bucket
# del state remoto no puede guardar el state de quien lo crea.

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
}

resource "google_storage_bucket" "tfstate" {
  name     = var.bucket_state
  location = var.ubicacion

  # Uniform access: permisos solo por IAM, sin ACLs por objeto que nadie audita.
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # Versionado: un state corrupto o pisado por error se recupera de la
  # versión anterior. Sin esto, perder el state es perder el mapa de qué
  # recursos existen y quién los creó.
  versioning {
    enabled = true
  }

  # Las versiones viejas se acumulan para siempre si nadie las poda.
  lifecycle_rule {
    condition {
      num_newer_versions = 20
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  # Ni Terraform puede borrar este bucket con objetos adentro.
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"
  description               = "Identidades de los workflows de GitHub Actions."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Sin esta condición, CUALQUIER repo de GitHub podría pedir un token a este
  # pool. Es el error más común —y más grave— al configurar WIF.
  attribute_condition = "assertion.repository == \"${var.repo_github}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Identidad del CI: solo planea. No tiene permisos para aplicar cambios.
resource "google_service_account" "ci_plan" {
  account_id   = "terraform-plan"
  display_name = "Terraform plan (GitHub Actions)"
  description  = "Lee la infraestructura y el state para correr terraform plan. No puede modificar nada."
}

resource "google_service_account_iam_member" "ci_plan_wif" {
  service_account_id = google_service_account.ci_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.repo_github}"
}

# Leer todo el proyecto para comparar contra el código...
resource "google_project_iam_member" "ci_plan_viewer" {
  for_each = toset(var.proyectos_a_planear)

  project = each.value
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.ci_plan.email}"
}

# ...y escribir en el bucket solo lo necesario para tomar el lock del state.
resource "google_storage_bucket_iam_member" "ci_plan_state" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.ci_plan.email}"
}
