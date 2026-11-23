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

Configure an OAuth authorization server used by API Management clients to obtain
access tokens. Required fields have no module default. Optional fields default
to null and leave provider/API behavior in control unless a default is stated.

Value types: parent selectors and timeouts are objects. Other leaves are strings
except the sets, boolean and list of parameter objects explicitly identified below.

- settings.name (required): Logical server name, processed by CAF naming and
  global naming controls; the resulting name identifies this APIM child.
- settings.display_name (required): Friendly server label shown to API consumers.
- settings.authorization_endpoint (required): OAuth endpoint where users authorize
  a client application, for example the authorization server's /authorize URL.
- settings.authorization_methods (required set of strings): HTTP methods accepted by that endpoint.
  Allowed values: DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT, TRACE; include GET.
- settings.client_id (required): Application identifier registered with the server.
- settings.client_registration_endpoint (required): URI of the page where clients
  register an application with this authorization server.
- settings.grant_types (required set of strings): Supported token grant flows; choose from
  authorizationCode, clientCredentials, implicit and resourceOwnerPassword.
- settings.bearer_token_sending_methods (optional set of strings): How callers send access tokens
  to the API: authorizationHeader and/or query. Null does not force either method.
- settings.client_authentication_method (optional set of strings): Token-endpoint client
  authentication mechanisms: Basic and/or Body.
- settings.client_secret (optional): Secret for the registered application; inject
  securely and protect Terraform state rather than committing a credential.
- settings.default_scope (optional): Space-delimited scopes requested by default.
- settings.description (optional): Explanatory server text; HTML formatting is allowed.
- settings.resource_owner_password (optional): Resource owner's password, allowed
  only when grant_types includes resourceOwnerPassword; treat as a credential.
- settings.resource_owner_username (optional): Resource owner's username; only
  configure it with the resourceOwnerPassword grant.
- settings.support_state (optional boolean): Whether clients may use OAuth state for protocol
  security. Null delegates behavior; the module does not force true or false.
- settings.token_endpoint (optional): OAuth endpoint used to exchange grants for tokens.
- settings.token_body_parameter (optional list of objects, defaults to [] even if null): Additional
  form parameters sent to the token endpoint; omission creates no parameter blocks.
- settings.token_body_parameter[].name (required per entry): Form parameter name.
- settings.token_body_parameter[].value (required per entry): Value sent under that name.

Parent selection must resolve both APIM and resource group names:
- settings.api_management_name (optional): Explicit parent service name; wins over
  settings.api_management.name and key lookup. Changing the parent recreates the child.
- settings.api_management (optional): Parent selection by name or remote output key.
- settings.api_management.name (optional): Direct service name when the top-level
  api_management_name is absent; takes precedence over key.
- settings.api_management.key (optional): Key in remote_objects.api_management for
  the parent; required for lookup when neither direct name is supplied.
- settings.api_management.lz_key (optional): Landing zone containing that key;
  omitted/null uses client_config.landingzone_key.
- settings.resource_group_name (optional): Explicit parent resource group name;
  wins over the reference object's name, key lookup and APIM-output fallback.
- settings.resource_group (optional): Select the parent service's resource group.
- settings.resource_group.name (optional): Direct group name, ahead of key lookup.
- settings.resource_group.key (optional): Key in remote_objects.resource_groups;
  if unresolved, the selected APIM output's resource_group_name is the final fallback.
- settings.resource_group.lz_key (optional): Group lookup landing zone;
  omitted/null uses client_config.landingzone_key, independently of the APIM reference.

- settings.timeouts (optional): Operation wait limits as duration strings, not retry
  intervals. Omitted/null creates no block; provider defaults remain in control.
  For a supplied object, omitted/null members use the module defaults listed below,
  which match the provider's documented operation limits.
- settings.timeouts.create (optional, default 30m): Maximum wait to create the server.
- settings.timeouts.read (optional, default 5m): Maximum wait to retrieve the server.
- settings.timeouts.update (optional, default 30m): Maximum wait to update server settings.
- settings.timeouts.delete (optional, default 30m): Maximum wait to remove the server.
DESCRIPTION
  type = object({
    name                         = string
    display_name                 = string
    authorization_endpoint       = string
    authorization_methods        = set(string)
    client_id                    = string
    client_registration_endpoint = string
    grant_types                  = set(string)
    bearer_token_sending_methods = optional(set(string))
    client_authentication_method = optional(set(string))
    client_secret                = optional(string)
    default_scope                = optional(string)
    description                  = optional(string)
    resource_owner_password      = optional(string)
    resource_owner_username      = optional(string)
    support_state                = optional(bool)
    token_endpoint               = optional(string)
    token_body_parameter = optional(list(object({
      name  = string
      value = string
    })), [])
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
