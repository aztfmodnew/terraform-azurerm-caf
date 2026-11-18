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

Customize the subject and HTML body of one built-in API Management notification
email template. Required fields have no module default. Optional parent selectors
default to null; provide enough direct names or key references to resolve both parents.

Value types: api_management, resource_group and timeouts are objects; all their
leaf fields and all other settings values are strings.

- settings.template_name (required): Built-in notification template to customize,
  not an arbitrary resource name or CAF naming input. Choose exactly one of:
  AccountClosedDeveloper, ApplicationApprovedNotificationMessage,
  ConfirmSignUpIdentityDefault, EmailChangeIdentityDefault,
  InviteUserNotificationMessage, NewCommentNotificationMessage,
  NewDeveloperNotificationMessage, NewIssueNotificationMessage,
  PasswordResetByAdminNotificationMessage, PasswordResetIdentityDefault,
  PurchaseDeveloperNotificationMessage,
  QuotaLimitApproachingDeveloperNotificationMessage,
  RejectDeveloperNotificationMessage, RequestDeveloperNotificationMessage.
  Changing the identifier selects a different template and recreates the resource.
- settings.subject (required): Subject line sent to the recipient. Template-specific
  $ParameterName placeholders are passed through to APIM for substitution.
- settings.body (required): Complete, well-formed HTML email document. It can use the
  same template-specific $ParameterName placeholders; consult the selected template
  in the APIM portal for the available parameters. It is not a file path or plain
  text message. Azure supplies the template's title and description as outputs.

- settings.api_management_name (optional): Explicit APIM service name, ahead of
  settings.api_management.name and remote key lookup.
- settings.api_management (optional): Select the APIM service that owns the template.
- settings.api_management.name (optional): Direct service name used when the
  top-level api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management;
  needed for lookup if neither direct service name is supplied.
- settings.api_management.lz_key (optional): Landing zone containing the service
  key; omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Explicit service resource group name,
  ahead of resource_group.name, its key lookup and the APIM-output fallback.
- settings.resource_group (optional): Select the group containing the APIM service.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups.
  The selected APIM output's resource_group_name is the final fallback if necessary.
- settings.resource_group.lz_key (optional): Group lookup landing zone; omitted/null
  uses client_config.landingzone_key independently of the APIM reference.
  Changing either resolved parent recreates the template resource.

- settings.timeouts (optional, default null): Maximum operation waits expressed as
  duration strings. Omitted/null emits no block and uses provider-owned defaults.
  In a supplied object, omitted/null members receive the module defaults below,
  matching the provider's documented limits; these are not email-delivery deadlines.
- settings.timeouts.create (optional, default 30m): Wait limit to configure the template.
- settings.timeouts.read (optional, default 5m): Wait limit to retrieve the template.
- settings.timeouts.update (optional, default 30m): Wait limit to change subject/body.
- settings.timeouts.delete (optional, default 30m): Wait limit for template deletion.
DESCRIPTION
  type = object({
    template_name       = string
    subject             = string
    body                = string
    api_management_name = optional(string)
    api_management = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    resource_group_name = optional(string)
    resource_group = optional(object({
      name   = optional(string)
      key    = optional(string)
      lz_key = optional(string)
    }))
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }))
  })
}
