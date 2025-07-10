azuread_applications = {
  test_client = {
    useprefix        = true
    application_name = "test-client"
    reply_urls       = ["https://example.azurewebsites.net/.auth/login/aad/callback"]
  }
}

azuread_service_principals = {
  sp1 = {
    azuread_application = {
      key = "test_client"
    }
    app_role_assignment_required = true
  }
}

azuread_service_principal_passwords = {
  sp1 = {
    azuread_service_principal = {
      key = "sp1"
    }
    password_policy = {
      length         = 250
      special        = false
      upper          = true
      number         = true
      expire_in_days = 10
      rotation = {
        mins = 3
      }
    }
  }
}
