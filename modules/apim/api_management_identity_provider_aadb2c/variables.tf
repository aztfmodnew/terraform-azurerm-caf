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

Connect the API Management developer portal to an existing Azure AD B2C tenant,
application and user-flow policies. This module configures the APIM connection;
it does not create the external tenant, application or policies. Required fields
have no module default; optional fields default to null unless stated.

Value types: parent selectors and timeouts are objects; all leaf fields are strings.

- settings.client_id (required): Client identifier of the application in the B2C tenant.
- settings.client_secret (required): Secret for that application. Inject securely,
  register the developer portal redirect URI and protect state containing the secret.
- settings.allowed_tenant (required): B2C tenant allowed to authenticate users,
  usually its tenant domain such as example.onmicrosoft.com.
- settings.authority (required): OpenID discovery authority hostname, normally the
  tenant's b2clogin.com hostname, not a complete policy XML document or policy name.
- settings.signin_tenant (required): Tenant used for sign-in instead of Common,
  normally the B2C tenant domain; distinct from the user-flow policy name.
- settings.signin_policy (required): Existing B2C sign-in policy/user-flow name,
  for example B2C_1_Login.
- settings.signup_policy (required): Existing B2C registration policy/user-flow
  name, for example B2C_1_Signup.
- settings.client_library (optional): Developer portal authentication client
  library identifier, for example MSAL-2; null leaves provider/API selection unchanged.
- settings.password_reset_policy (optional): Existing B2C password-reset user-flow
  name; null does not configure a custom reset flow.
- settings.profile_editing_policy (optional): Existing B2C profile-editing
  user-flow name; null does not configure a custom profile editing flow.

- settings.api_management_name (optional): Direct APIM service name, ahead of
  api_management.name and remote key lookup.
- settings.api_management (optional): Select the service receiving the B2C connection.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; wins over key.
- settings.api_management.key (optional): Key in remote_objects.api_management
  when the service is not selected by a direct name.
- settings.api_management.lz_key (optional): Service lookup landing zone;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Direct service resource group name,
  ahead of resource_group.name, its key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the resource group owning the service.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  the resolved APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key independently of service lookup.
  Both parent names must resolve; changing a parent recreates this APIM child.

- settings.timeouts (optional): Duration-string limits for infrastructure operations.
  Omitted/null emits no block and retains provider defaults. For a supplied object,
  omitted/null members use the module defaults below, matching provider limits.
  These limits do not set authentication token or user session lifetimes.
- settings.timeouts.create (optional, default 30m): Wait to configure the B2C provider.
- settings.timeouts.read (optional, default 5m): Wait to retrieve the provider settings.
- settings.timeouts.update (optional, default 30m): Wait to change the B2C connection.
- settings.timeouts.delete (optional, default 30m): Wait to remove the APIM connection.
DESCRIPTION
  type = object({
    client_id              = string
    client_secret          = string
    allowed_tenant         = string
    authority              = string
    signin_tenant          = string
    signin_policy          = string
    signup_policy          = string
    client_library         = optional(string)
    password_reset_policy  = optional(string)
    profile_editing_policy = optional(string)
    api_management_name    = optional(string)
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
