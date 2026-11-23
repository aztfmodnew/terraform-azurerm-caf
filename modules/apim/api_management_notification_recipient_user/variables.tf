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

Subscribe an existing API Management user to one class of service notifications.
Required fields have no module default; optional selectors default to null. The
user must belong to the selected APIM service. No CAF name is generated.

Value types: user, api_management and timeouts are objects; all leaf fields are strings.

- settings.notification_type (required): Notification class to receive. Supported
  values: AccountClosedPublisher, BCC, NewApplicationNotificationMessage,
  NewIssuePublisherNotificationMessage, PurchasePublisherNotificationMessage,
  QuotaLimitApproachingPublisherNotificationMessage,
  RequestPublisherNotificationMessage. A change replaces the subscription.
- settings.user_id (optional): Direct APIM-local user identifier, not the user's full
  ARM ID. Takes precedence over user.user_id and remote user lookup.
- settings.user (optional): Select the existing recipient user, without creating one.
- settings.user.user_id (optional): Direct APIM-local identifier used when the
  top-level user_id is absent; takes precedence over key lookup.
- settings.user.key (optional): Key in remote_objects.api_management_users.
  The referenced entry's user_id is preferred; if it exposes only an ARM id, the
  module extracts its final path segment for compatibility with existing user outputs.
- settings.user.lz_key (optional): Landing zone containing the user key;
  omitted/null uses client_config.landingzone_key.
- settings.api_management_id (optional): Direct service ARM ID; wins over
  api_management.id and remote APIM lookup.
- settings.api_management (optional): Select the service that owns the recipient user.
- settings.api_management.id (optional): Direct service ARM ID when the top-level
  api_management_id is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management,
  needed when neither direct service ID is supplied.
- settings.api_management.lz_key (optional): Service lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of user lookup.
  Both identifiers must resolve; changing the service or user replaces the subscription.

- settings.timeouts (optional, default null): Duration-string operation wait limits,
  not notification-delivery deadlines. Omitted/null emits no block and retains
  provider defaults. In a supplied object, omitted/null members use the module
  defaults below, matching provider limits. No update operation/timeout is supported.
- settings.timeouts.create (optional, default 30m): Wait to add the user subscription.
- settings.timeouts.read (optional, default 5m): Wait to retrieve subscription settings.
- settings.timeouts.delete (optional, default 30m): Wait to remove the user subscription.
DESCRIPTION
  type = object({
    notification_type = string
    user_id           = optional(string)
    user = optional(object({
      user_id = optional(string)
      key     = optional(string)
      lz_key  = optional(string)
    }))
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
