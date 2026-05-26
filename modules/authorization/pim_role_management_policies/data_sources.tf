locals {
  policy_scope_management_group_data_lookup = (
    try(local.scope_management_group_selector.key, null) == null && (
      try(local.scope_management_group_selector.name, null) != null ||
      try(local.scope_management_group_selector.display_name, null) != null
    )
    ) ? {
    this = local.scope_management_group_selector
  } : {}

  policy_scope_subscription_data_lookup = (
    try(local.scope_subscription_selector.key, null) == null &&
    try(local.scope_subscription_selector.subscription_id, null) != null
    ) ? {
    this = local.scope_subscription_selector
  } : {}

  policy_scope_subscription_display_name_lookup = (
    try(local.scope_subscription_selector.key, null) == null &&
    try(local.scope_subscription_selector.subscription_id, null) == null &&
    try(local.scope_subscription_selector.display_name, null) != null
    ) ? {
    this = local.scope_subscription_selector
  } : {}

  policy_role_definition_data_lookup = (
    try(local.role_definition_selector.key, null) == null && (
      try(local.role_definition_selector.name, null) != null ||
      try(local.role_definition_selector.role_definition_id, null) != null
    )
    ) ? {
    this = local.role_definition_selector
  } : {}
}

data "azurerm_management_group" "policy_scope_management_group" {
  for_each = local.policy_scope_management_group_data_lookup

  name         = try(each.value.name, null)
  display_name = try(each.value.display_name, null)
}

data "azurerm_subscription" "policy_scope_subscription" {
  for_each = local.policy_scope_subscription_data_lookup

  subscription_id = each.value.subscription_id
}

data "azurerm_subscriptions" "policy_scope_subscription_display_name_candidates" {
  for_each = local.policy_scope_subscription_display_name_lookup

  display_name_contains = each.value.display_name
}

locals {
  policy_scope_subscription_display_name_exact_matches = {
    for key, value in local.policy_scope_subscription_display_name_lookup : key => [
      for subscription in try(data.azurerm_subscriptions.policy_scope_subscription_display_name_candidates[key].subscriptions, []) : subscription
      if lower(trimspace(try(subscription.display_name, ""))) == lower(trimspace(value.display_name))
    ]
  }

  policy_scope_subscription_display_name_lookup_with_id = {
    for key, value in local.policy_scope_subscription_display_name_lookup : key => merge(
      value,
      {
        subscription_id = local.policy_scope_subscription_display_name_exact_matches[key][0].subscription_id
      }
    )
    if length(local.policy_scope_subscription_display_name_exact_matches[key]) == 1
  }
}

resource "terraform_data" "policy_scope_subscription_display_name_guard" {
  for_each = local.policy_scope_subscription_display_name_lookup

  input = {
    key          = each.key
    display_name = each.value.display_name
  }

  lifecycle {
    precondition {
      condition = length(local.policy_scope_subscription_display_name_exact_matches[each.key]) == 1
      error_message = format(
        "settings.subscription/scope_subscription display_name %q resolved %d exact matches; expected exactly 1. Use subscription_id for deterministic resolution when names are not unique.",
        each.value.display_name,
        length(local.policy_scope_subscription_display_name_exact_matches[each.key])
      )
    }
  }
}

data "azurerm_subscription" "policy_scope_subscription_display_name" {
  for_each = local.policy_scope_subscription_display_name_lookup_with_id

  subscription_id = each.value.subscription_id
}

data "azurerm_role_definition" "policy_role_definition" {
  for_each = local.policy_role_definition_data_lookup

  name               = try(each.value.name, null)
  role_definition_id = try(each.value.role_definition_id, null)
  scope              = try(each.value.scope, null)
}

locals {
  policy_scope_from_management_group_data = try(data.azurerm_management_group.policy_scope_management_group["this"].id, null)
  policy_scope_from_subscription_data = try(coalesce(
    try(data.azurerm_subscription.policy_scope_subscription["this"].id, null),
    try(data.azurerm_subscription.policy_scope_subscription_display_name["this"].id, null)
  ), null)
  policy_role_definition_from_data = try(data.azurerm_role_definition.policy_role_definition["this"].id, null)
}