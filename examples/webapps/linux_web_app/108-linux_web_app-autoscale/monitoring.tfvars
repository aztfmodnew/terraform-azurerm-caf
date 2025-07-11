monitor_autoscale_settings = {
  mas1 = {
    name               = "mas1"
    enabled            = true
    resource_group_key = "rg1"

    target_resource = {
      service_plan_key = "sp1"
    }

    profiles = {
      profile1 = {
        name = "profile1"

        capacity = {
          default = 1
          minimum = 1
          maximum = 3
        }

        rules = {
          rule1 = {
            metric_trigger = {
              metric_name      = "CpuPercentage"
              metric_namespace = "microsoft.web/serverfarms"
              time_grain       = "PT1M"
              statistic        = "Average"
              time_window      = "PT10M"
              time_aggregation = "Average"
              operator         = "GreaterThan"
              threshold        = 70
            }

            scale_action = {
              direction = "Increase"
              type      = "ChangeCount"
              value     = 1
              cooldown  = "PT10M"
            }
          }

          rule2 = {
            metric_trigger = {
              metric_name      = "CpuPercentage"
              metric_namespace = "microsoft.web/serverfarms"
              time_grain       = "PT1M"
              statistic        = "Average"
              time_window      = "PT10M"
              time_aggregation = "Average"
              operator         = "LessThan"
              threshold        = 25
            }

            scale_action = {
              direction = "Decrease"
              type      = "ChangeCount"
              value     = 1
              cooldown  = "PT10M"
            }
          }
        }

        fixed_date = {
          timezone = "UTC"
        }
      }
    }
  }
}
