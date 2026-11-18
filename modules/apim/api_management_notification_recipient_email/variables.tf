variable "global_settings" {
  description = "Global settings object (see module README.md)."
  type        = any
  default     = {}
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
  type        = any
  default     = {}
}
variable "remote_objects" {
  description = "Remote objects configuration."
  type        = any
  default     = {}
}
variable "settings" {
  description = <<DESCRIPTION
Undeclared attributes are ignored by Terraform's object type conversion.

Subscribe an email address to one class of API Management service notifications.
Required fields have no module default; optional parent selectors default to null.
The recipient is identified by its email and notification type, not a CAF name.

Value types: api_management and timeouts are objects; all leaf fields are strings.

- settings.email (required): Mailbox address that should receive this notification
  class. Changing the address replaces the subscription.
- settings.notification_type (required): Event class to receive. Supported values:
  AccountClosedPublisher, BCC, NewApplicationNotificationMessage,
  NewIssuePublisherNotificationMessage, PurchasePublisherNotificationMessage,
  QuotaLimitApproachingPublisherNotificationMessage,
  RequestPublisherNotificationMessage. Changing the class replaces the subscription.
- settings.api_management_id (optional): Direct parent service ARM ID, ahead of
  api_management.id and remote key lookup. A service name alone is not sufficient.
- settings.api_management (optional): Select the service whose notifications to receive.
- settings.api_management.id (optional): Direct service ARM ID used when the
  top-level api_management_id is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management,
  required for lookup when neither direct service ID is supplied.
- settings.api_management.lz_key (optional): Landing zone containing that key;
  omitted/null uses client_config.landingzone_key.
  The parent ID must resolve; moving to another service replaces the subscription.

- settings.timeouts (optional, default null): Duration-string operation wait limits.
  Omitted/null emits no block and retains provider defaults. In a supplied object,
  omitted/null members use the module defaults below, matching provider limits.
  There is no update operation or update timeout; changes replace the recipient.
  These limits do not control notification-delivery latency.
- settings.timeouts.create (optional, default 30m): Wait limit to add the recipient.
- settings.timeouts.read (optional, default 5m): Wait limit to retrieve the subscription.
- settings.timeouts.delete (optional, default 30m): Wait limit to remove the recipient.
DESCRIPTION
  type = object({
    email             = string
    notification_type = string
    api_management_id = optional(string)
    api_management = optional(object({
      id     = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      delete = optional(string, "30m")
    }))
  })
}
