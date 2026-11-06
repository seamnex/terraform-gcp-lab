# Entorno dev: lo más barato que todavía ejercita todo el diseño.
# Reemplazá project_id por tu proyecto de dev antes de un plan real.

project_id = "REEMPLAZAR-proyecto-dev"
entorno    = "dev"
region     = "us-central1"
zonas      = ["us-central1-a"]
cidr       = "10.10.0.0/24"

# e2-micro: entra en el free tier de Compute Engine (una por cuenta, en
# us-central1, us-east1 o us-west1). Spot no aplica al free tier, así que
# queda apagado: con una sola VM gratis, Spot solo agregaría interrupciones.
tipo_maquina = "e2-micro"
# El free tier cubre 30 GB de disco *standard*, no balanced.
tipo_disco = "pd-standard"
replicas   = 1
spot       = false

imagen = "ghcr.io/seamnex/cicd-pipeline:0.1.0"

# Flow logs al 10 % y agregados cada 10 minutos: alcanza para investigar,
# y es la diferencia entre centavos y algunos dólares de Logging al mes.
flow_logs = {
  muestreo  = 0.1
  intervalo = "INTERVAL_10_MIN"
}
