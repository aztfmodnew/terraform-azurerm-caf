check "api_center_arm_names" {
  assert {
    condition = alltrue([
      for name in local.arm_names :
      can(regex("^[a-zA-Z0-9-]{3,90}$", name))
    ])
    error_message = "API Center names must be 3-90 alphanumeric or hyphen characters, matching the stable ARM schema."
  }
}
