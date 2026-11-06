locals {
  nombre  = "lab-${var.entorno}"
  tag_app = "${local.nombre}-app"
}

module "network" {
  source = "../../modules/network"

  project_id = var.project_id
  nombre     = local.nombre
  region     = var.region
  cidr       = var.cidr
  tag_app    = local.tag_app
  puerto_app = var.puerto_app
  flow_logs  = var.flow_logs
}

module "iam" {
  source = "../../modules/iam"

  project_id = var.project_id
  nombre     = local.nombre
}

module "compute" {
  source = "../../modules/compute"

  project_id            = var.project_id
  nombre                = local.nombre
  region                = var.region
  zonas                 = var.zonas
  subred_id             = module.network.subred_id
  service_account_email = module.iam.email
  tag_app               = local.tag_app
  tipo_maquina          = var.tipo_maquina
  tipo_disco            = var.tipo_disco
  replicas              = var.replicas
  spot                  = var.spot
  imagen                = var.imagen
  puerto_app            = var.puerto_app
}
