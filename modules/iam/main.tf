# Identidad con la que corren las VMs.
#
# Una service account propia, con lo mínimo para escribir logs y métricas.
# La alternativa por defecto —la service account de Compute Engine— tiene el
# rol Editor sobre todo el proyecto: una VM comprometida podría borrar el
# resto de la infraestructura.

resource "google_service_account" "vm" {
  project      = var.project_id
  account_id   = "${var.nombre}-vm"
  display_name = "VMs de ${var.nombre}"
  description  = "Identidad de las VMs de la app. Solo escribe logs y métricas."
}

# `google_project_iam_member` y no `_binding` ni `_policy`: agrega este
# miembro sin tocar a nadie más. Un `_policy` es autoritativo sobre el
# proyecto entero y un `apply` borraría los permisos que Terraform no conoce,
# incluidos los de quien lo está corriendo.
resource "google_project_iam_member" "vm" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm.email}"
}
