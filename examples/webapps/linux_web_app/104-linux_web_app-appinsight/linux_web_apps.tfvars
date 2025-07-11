linux_web_apps = {
  webapp1 = {
    resource_group_key      = "webapp_simple"
    name                    = "webapp-simple"
    service_plan_key        = "sp1"
    application_insight_key = "app_insights1"

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }
  }
}
