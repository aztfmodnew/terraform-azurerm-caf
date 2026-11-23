global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}
resource_groups = {
  gateway = { name = "email-gateway", region = "region1" }
}
api_management = {
  gateway = {
    name            = "email-gateway"
    region          = "region1"
    resource_group  = { key = "gateway" }
    publisher_name  = "Example"
    publisher_email = "operations@example.com"
    sku_name        = "Developer_1"
  }
}
api_management_email_template = {
  signup = {
    template_name  = "ConfirmSignUpIdentityDefault"
    subject        = "Confirm your $OrganizationName API account"
    body           = "<!DOCTYPE html><html><head><title>Confirm account</title></head><body><p>Dear $DevFirstName $DevLastName,</p><p>Please confirm your account using <a href=\"$ConfirmUrl\">this link</a>.</p></body></html>"
    api_management = { key = "gateway" }
    resource_group = { key = "gateway" }
  }
}
