variable "apex_function_ping" {}
variable "apex_function_health_check" {}

module "phase0" {
  source = "phase0"
}

module "phase1" {
  source                     = "phase1"
  apex_function_ping         = "${var.apex_function_ping}"
  apex_function_health_check = "${var.apex_function_health_check}"
}
