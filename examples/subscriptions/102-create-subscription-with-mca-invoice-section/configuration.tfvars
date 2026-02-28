global_settings = {
  default_region = "region1"
  regions = {
    region1 = "eastus"
  }
}

resource_groups = {
  rg1 = {
    name   = "example-billing"
    region = "region1"
  }
}

subscriptions = {
  sandbox = {
    name                 = "my-sandbox"
    create_alias         = true
    billing_account_name = "0000000-0000-0000-0000-0000000:000000-000000-000000-000000-000000_2019-05-31"
    billing_profile_name = "XXXX-XXXX-XXX-XXX"
    invoice_section_key  = "section_1"
    management_group_id  = "caf-sandbox-landingzones"
    workload             = "DevTest"
    tags = {
      owner = "Cloud Platform Team"
    }
  }
}

invoice_sections = {
  section_1 = {
    name               = "sandbox-automation-invoice-section"
    billing_account_id = "0000000-0000-0000-0000-0000000:000000-000000-000000-000000-000000_2019-05-31"
    billing_profile_id = "XXXX-XXXX-XXX-XXX"
    labels = {
      "foo" = "baz"
    }
    tags = {
      "tagA" = "valueA"
    }
  }
}
