# Usado SOLO por el CI cuando no hay credenciales de GCP configuradas.
#
# Terraform aplica los archivos *_override.tf después del resto, así que este
# bloque reemplaza el backend "gcs" por uno local. Permite correr un plan
# contra un state vacío —qué se crearía desde cero— sin tocar el bucket real.
# El workflow lo copia al entorno antes del init; nunca se commitea dentro
# de envs/.
terraform {
  backend "local" {}
}
