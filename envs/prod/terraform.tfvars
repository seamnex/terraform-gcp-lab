# Entorno prod: dos zonas, para que la caída de una zona no sea una caída.
# Reemplazá project_id por tu proyecto de prod antes de un plan real.

project_id = "REEMPLAZAR-proyecto-prod"
entorno    = "prod"
region     = "us-central1"
zonas      = ["us-central1-a", "us-central1-b"]
cidr       = "10.20.0.0/24"

# Dos e2-small, una por zona. Sin Spot: en prod una VM reclamada por GCP es
# capacidad perdida justo cuando más se la necesita.
tipo_maquina = "e2-small"
tipo_disco   = "pd-balanced"
replicas     = 3
spot         = false

imagen = "ghcr.io/seamnex/cicd-pipeline:0.1.0"

# Flow logs con más detalle: en prod se investiga más, y vale el costo.
flow_logs = {
  muestreo  = 0.5
  intervalo = "INTERVAL_5_SEC"
}
