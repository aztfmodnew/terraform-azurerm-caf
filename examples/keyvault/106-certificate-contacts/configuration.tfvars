global_settings = {
  default_region = "region1"
  regions        = { region1 = "westeurope" }
  random_length  = 5
}

resource_groups = {
  contacts = {
    name = "certificate-contacts"
  }
}

keyvaults = {
  contacts = {
    name = "contacts"
    resource_group = {
      key = "contacts"
    }
    sku_name = "standard"
    creation_policies = {
      logged_in_user = {
        certificate_permissions = ["ManageContacts"]
      }
    }
    contacts = {
      primary = {
        email = "primary@example.com"
        name  = "Primary contact"
      }
      secondary = {
        email = "secondary@example.com"
      }
    }
  }
}
