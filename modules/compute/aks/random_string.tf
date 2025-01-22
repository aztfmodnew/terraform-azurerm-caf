resource "random_string" "prefix" {
  length  = 10
  special = false
  upper   = false
  numeric = false
}
