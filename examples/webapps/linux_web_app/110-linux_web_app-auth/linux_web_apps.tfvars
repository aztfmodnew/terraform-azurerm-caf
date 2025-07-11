linux_web_apps = {
  webapp1 = {
    resource_group_key = "webapp_simple"
    name               = "webapp-simple"
    service_plan_key   = "sp1"

    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "6.9.1"
    }

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }

    auth_settings = {
      enabled                       = true
      unauthenticated_client_action = "RedirectToLoginPage"
      issuer                        = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000"
      active_directory = {
        client_id_key     = "test_client"
        client_secret_key = "sp1"
      }
    }
  }
}
