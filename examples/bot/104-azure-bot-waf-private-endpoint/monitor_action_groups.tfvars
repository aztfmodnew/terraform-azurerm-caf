# Monitor Action Groups for Bot Infrastructure Alerting
monitor_action_groups = {
  bot_security_alerts = {
    action_group_name  = "bot-security-alerts"
    resource_group_key = "bot_rg"
    shortname          = "botsecalert"

    email_receiver = {
      security_team = {
        name                    = "Security Team"
        email_address           = "security@example.com"
        use_common_alert_schema = true
      },
      bot_team = {
        name                    = "Bot Team"
        email_address           = "bot-team@example.com"
        use_common_alert_schema = true
      }
    }

    # Uncomment if SMS alerts are needed
    # sms_receiver = {
    #   on_call = {
    #     name         = "On-Call"
    #     country_code = "1"
    #     phone_number = "5551234567"
    #   }
    # }

    webhook_receiver = {
      teams_webhook = {
        name        = "teams-webhook-security"
        service_uri = "https://outlook.office.com/webhook/your-webhook-url"
      }
    }

    tags = {
      monitoring = "alerting"
      purpose    = "security-notifications"
      service    = "bot"
    }
  },

  bot_performance_alerts = {
    action_group_name  = "bot-performance-alerts"
    resource_group_key = "bot_rg"
    shortname          = "botperfalert"

    email_receiver = {
      bot_team = {
        name                    = "Bot Team"
        email_address           = "bot-team@example.com"
        use_common_alert_schema = true
      },
      devops_team = {
        name                    = "DevOps Team"
        email_address           = "devops@example.com"
        use_common_alert_schema = true
      }
    }

    webhook_receiver = {
      slack_webhook = {
        name        = "slack-webhook-performance"
        service_uri = "https://hooks.slack.com/services/your-webhook-url"
      }
    }

    tags = {
      monitoring = "alerting"
      purpose    = "performance-notifications"
      service    = "bot"
    }
  }
}
