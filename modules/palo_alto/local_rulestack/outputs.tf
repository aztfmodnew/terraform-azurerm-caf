output "id" {
  description = "The ID of the Local Rulestack."
  value       = azurerm_palo_alto_local_rulestack.local_rulestack.id
}

output "name" {
  description = "The name of the Local Rulestack."
  value       = azurerm_palo_alto_local_rulestack.local_rulestack.name
}

output "certificates" {
  description = "Details of the certificates created in the rulestack."
  value       = azurerm_palo_alto_local_rulestack_certificate.local_rulestack_certificate
}

output "fqdn_lists" {
  description = "Details of the FQDN lists created in the rulestack."
  value       = azurerm_palo_alto_local_rulestack_fqdn_list.local_rulestack_fqdn_list
}

output "prefix_lists" {
  description = "Details of the prefix lists created in the rulestack."
  value       = azurerm_palo_alto_local_rulestack_prefix_list.local_rulestack_prefix_list
}

output "rules_output" { # Renamed to avoid conflict with rules.tf file name if it were an output
  description = "Details of the rules created in the rulestack."
  value       = azurerm_palo_alto_local_rulestack_rule.local_rulestack_rule
}

output "outbound_trust_certificate_associations" {
  description = "Details of the outbound trust certificate associations."
  value       = azurerm_palo_alto_local_rulestack_outbound_trust_certificate_association.local_rulestack_outbound_trust_certificate_association
}

output "outbound_untrust_certificate_associations" {
  description = "Details of the outbound untrust certificate associations."
  value       = azurerm_palo_alto_local_rulestack_outbound_untrust_certificate_association.local_rulestack_outbound_untrust_certificate_association
}
