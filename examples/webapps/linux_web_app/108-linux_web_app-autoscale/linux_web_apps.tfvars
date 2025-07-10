linux_web_apps = {
  webapp1 = {
    resource_group_key = "rg1"
    name               = "webapp-simple-autoscale"
    service_plan_key   = "sp1"

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }
  }
}
