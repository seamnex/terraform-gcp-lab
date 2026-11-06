# Cómputo: un grupo de instancias administrado (MIG) regional que corre la
# imagen publicada por el pipeline de cicd-pipeline sobre Container-Optimized OS.
#
# Por qué un MIG y no una VM suelta, aun en dev con una sola instancia: el MIG
# recrea la VM si el health check falla (autohealing) y hace rolling updates
# cuando cambia el template. Una VM suelta que se cuelga a las 3 AM espera a
# que alguien se despierte.

resource "google_compute_instance_template" "app" {
  project = var.project_id

  # name_prefix + create_before_destroy: un template no se puede modificar,
  # solo reemplazar. Así el nuevo existe antes de que el MIG suelte el viejo.
  name_prefix  = "${var.nombre}-"
  machine_type = var.tipo_maquina
  region       = var.region
  tags         = [var.tag_app]

  labels = var.etiquetas

  disk {
    # Familia y no versión fija: COS se actualiza solo con parches de
    # seguridad. El template guarda la imagen resuelta al momento de crearse.
    source_image = "cos-cloud/cos-stable"
    disk_type    = var.tipo_disco
    disk_size_gb = 10
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subred_id
    # Sin bloque access_config: la VM no tiene IP pública. Sale por Cloud NAT.
  }

  service_account {
    email = var.service_account_email
    # El scope amplio es lo recomendado hoy: lo que la VM puede hacer lo
    # limitan los roles IAM de la service account, no los scopes.
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    # Acceso SSH por OS Login (identidad de Google + IAM), no por claves
    # sueltas en la metadata del proyecto que nadie rota.
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      imagen = var.imagen
      puerto = var.puerto_app
    })
  }

  scheduling {
    # En dev se pueden usar VMs Spot (hasta ~60-90 % más baratas, pero GCP
    # puede reclamarlas). El autohealing del MIG las vuelve a crear.
    preemptible                 = var.spot
    provisioning_model          = var.spot ? "SPOT" : "STANDARD"
    automatic_restart           = !var.spot
    on_host_maintenance         = var.spot ? "TERMINATE" : "MIGRATE"
    instance_termination_action = var.spot ? "STOP" : null
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "app" {
  project = var.project_id
  name    = "${var.nombre}-hc"

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = var.puerto_app
    request_path = "/healthz"
  }

  log_config {
    enable = true
  }
}

resource "google_compute_region_instance_group_manager" "app" {
  project            = var.project_id
  name               = "${var.nombre}-mig"
  region             = var.region
  base_instance_name = var.nombre

  distribution_policy_zones = var.zonas
  target_size               = var.replicas

  version {
    instance_template = google_compute_instance_template.app.self_link_unique
  }

  named_port {
    name = "http"
    port = var.puerto_app
  }

  auto_healing_policies {
    health_check = google_compute_health_check.app.id
    # Tiempo para que COS arranque, baje la imagen y la app escuche. Si es
    # menor que eso, el MIG mata VMs sanas que todavía están arrancando y
    # entra en un loop de recreación que parece un incidente.
    initial_delay_sec = var.gracia_autohealing_seg
  }

  update_policy {
    type           = "PROACTIVE"
    minimal_action = "REPLACE"
    # Nunca bajar de la capacidad declarada durante un deploy: primero se
    # crea la VM nueva, después se borra la vieja. En un MIG regional el
    # surge fijo tiene que ser 0 o al menos la cantidad de zonas.
    max_surge_fixed       = length(var.zonas)
    max_unavailable_fixed = 0
  }
}
