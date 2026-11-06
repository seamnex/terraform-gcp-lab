# State remoto en el bucket que crea bootstrap/.
#
# Un prefijo por entorno: dev y prod nunca comparten state, así que un apply
# en dev no puede, ni por error, planear cambios sobre prod. El bucket tiene
# versionado, y GCS hace locking nativo: dos applies simultáneos no corrompen
# el state, el segundo espera o falla.
#
# El nombre del bucket no es una variable porque Terraform no lo permite en
# el bloque backend. Reemplazalo por el que devolvió bootstrap/ o pasalo al
# inicializar:
#   terraform init -backend-config="bucket=<tu-bucket>"
terraform {
  backend "gcs" {
    bucket = "REEMPLAZAR-tfstate"
    prefix = "terraform-gcp-lab/dev"
  }
}
