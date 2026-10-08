resource "azurerm_key_vault_certificate_contacts" "contacts" {
  for_each = try(var.settings.contacts, null) == null ? {} : (length(var.settings.contacts) == 0 ? {} : { contacts = var.settings.contacts })

  key_vault_id = azurerm_key_vault.keyvault.id

  dynamic "contact" {
    for_each = each.value

    content {
      email = contact.value.email
      name  = try(contact.value.name, null)
      phone = try(contact.value.phone, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.contacts_timeouts, null) == null ? [] : [var.settings.contacts_timeouts]

    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }

  depends_on = [time_sleep.initial_policy]
}
