# Red del entorno: una VPC en modo custom, una subred, salida a internet por
# Cloud NAT y el firewall mínimo para que las VMs funcionen sin IP pública.
#
# Ninguna VM de este lab tiene IP externa. Entran solo dos cosas:
#   - SSH a través de IAP (Identity-Aware Proxy), autenticado con la cuenta de Google
#   - los health checks de Google, que alimentan el autohealing del MIG

resource "google_compute_network" "vpc" {
  project = var.project_id
  name    = "${var.nombre}-vpc"

  # Modo custom: las subredes se declaran acá. El modo auto crea una subred
  # por región con rangos fijos que después chocan con cualquier peering.
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "principal" {
  project       = var.project_id
  name          = "${var.nombre}-${var.region}"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.cidr

  # Las VMs sin IP pública igual pueden hablar con las APIs de Google
  # (Logging, Monitoring, Artifact Registry) sin pasar por el NAT.
  private_ip_google_access = true

  # Flow logs muestreados: sin ellos, "¿esta VM llegó a hablar con aquel
  # destino?" no tiene respuesta durante un incidente. El muestreo y el
  # intervalo los ajusta cada entorno, porque es lo que define el costo.
  log_config {
    aggregation_interval = var.flow_logs.intervalo
    flow_sampling        = var.flow_logs.muestreo
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.nombre}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Salida a internet para bajar la imagen de ghcr.io y los paquetes del SO,
# sin darle a cada VM una IP pública.
resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "${var.nombre}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.principal.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Rangos documentados por Google. Están acá y no como variable porque no
# son una decisión del entorno: si cambian, cambian para todos.
locals {
  rango_iap           = ["35.235.240.0/20"]
  rangos_health_check = ["35.191.0.0/16", "130.211.0.0/22"]
}

resource "google_compute_firewall" "ssh_iap" {
  project     = var.project_id
  name        = "${var.nombre}-allow-ssh-iap"
  network     = google_compute_network.vpc.id
  description = "SSH solo desde IAP: autenticado con identidad de Google, sin puerto 22 abierto a internet."
  direction   = "INGRESS"

  source_ranges = local.rango_iap
  target_tags   = [var.tag_app]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "health_checks" {
  project     = var.project_id
  name        = "${var.nombre}-allow-health-checks"
  network     = google_compute_network.vpc.id
  description = "Health checks de Google contra la app. Sin esta regla el autohealing ve todas las VMs caídas y las recrea en loop."
  direction   = "INGRESS"

  source_ranges = local.rangos_health_check
  target_tags   = [var.tag_app]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.puerto_app)]
  }
}
