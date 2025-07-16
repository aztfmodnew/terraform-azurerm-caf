output "result" {
  description = "The generated resource name"
  value       = local.final_name
}

output "abbreviation" {
  description = "The abbreviation used for the resource type"
  value       = local.abbreviation
}

output "components" {
  description = "The name components that were used to build the name"
  value = {
    prefix       = var.prefix
    abbreviation = local.abbreviation
    name         = var.name
    environment  = var.environment
    region       = var.region
    instance     = var.instance
    suffix       = var.suffix
    separator    = var.separator
    component_order = var.component_order
  }
}

output "conversions" {
  description = "Shows original values and their converted abbreviations"
  value = {
    environment = {
      original   = var.environment
      converted  = local.environment_abbr
    }
    region = {
      original   = var.region
      converted  = local.region_abbr
    }
  }
}

output "constraints" {
  description = "The naming constraints applied to this resource type"
  value       = local.constraints
}

output "validation" {
  description = "Validation information for the generated name"
  value = {
    name_length     = length(local.final_name)
    min_length      = local.constraints.min_length
    max_length      = local.constraints.max_length
    is_valid_length = length(local.final_name) >= local.constraints.min_length && length(local.final_name) <= local.constraints.max_length
    allowed_chars   = local.constraints.allowed_chars
    case_sensitive  = local.constraints.case_sensitive
    global_unique   = local.constraints.global_unique
  }
}

output "random_suffix" {
  description = "The random suffix that was added (if any)"
  value       = var.add_random && length(random_string.suffix) > 0 ? random_string.suffix[0].result : ""
}

output "raw_name" {
  description = "The raw name before applying constraints and cleaning"
  value       = local.raw_name
}
