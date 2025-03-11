windows_web_apps = {
  webapp1 = {
    name               = "example-webapp"
    resource_group_key = "rg1"
    service_plan_key   = "sp1"
    settings = {
      enabled = true
    }
    app_settings = {
      "WEBSITE_NODE_DEFAULT_VERSION" = "14.17.0"
    }
    tags = {
      project = "example-project"
    }
  }
}