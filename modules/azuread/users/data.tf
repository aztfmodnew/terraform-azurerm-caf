
data "azuread_domains" "aad_domains" {
  only_initial = true
}