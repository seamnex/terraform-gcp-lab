# tflint atrapa lo que `terraform validate` deja pasar: tipos de máquina que
# no existen, variables declaradas y nunca usadas, convenciones de nombres.
config {
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "google" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
