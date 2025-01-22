
# trunk-ignore(tflint/terraform_required_providers)
resource "azuread_service_principal_password" "pwd" {
  display_name         = try(var.settings.display_name, null)
  service_principal_id = var.service_principal_id
  end_date             = try(timeadd(time_rotating.pwd.id, format("%sh", local.password_policy.expire_in_days * 24)), var.settings.end_date)

  rotate_when_changed = {
    rotation = time_rotating.pwd.id
  }
  start_date = try(var.settings.start_date, null)

  lifecycle {
    #create_before_destroy = false
  }
}

locals {
  password_policy = try(var.settings.password_policy, var.password_policy)
}

# trunk-ignore(tflint/terraform_required_providers)
resource "time_rotating" "pwd" {
  rotation_minutes = try(local.password_policy.rotation.mins, null)
  rotation_days    = try(local.password_policy.rotation.days, null)
  rotation_months  = try(local.password_policy.rotation.months, null)
  rotation_years   = try(local.password_policy.rotation.years, null)
}

# Will force the password to change every month
