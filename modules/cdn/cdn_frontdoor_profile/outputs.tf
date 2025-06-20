output "id" {
  value = module.profile.id
}
output "resource_guid" {
  value = module.profile.resource_guid
}

output "endpoint_id" {
  value = module.endpoint.endpoint_id
}

output "origin_group_id" {
  value = module.origin_group.origin_group_id
}

output "origin_id" {
  value = module.origin.origin_id
}

output "rule_set_id" {
  value = module.rule_set.rule_set_id
}

output "frontdoor_rule_id" {
  value = module.rule.frontdoor_rule_id
}

output "secret_id" {
  value = module.secret.secret_id
}

output "security_policy_id" {
  value = module.security_policy.id
}

output "custom_domain_association_id" {
  value = module.custom_domain_association.custom_domain_association_id
}
