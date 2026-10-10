variable "name" {
  description = "(Required) Specifies the name of the Application Insights WebTest. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. It needs to correlate with location of parent resource (azurerm_application_insights)."
  type        = string
}

variable "resource_group_id" {
  description = "(Required) The id of the resource group in which to create the Application Insights WebTest. Changing this forces a new resource."
  type        = string
}

variable "application_insights_id" {
  description = "(Required) The ID of the Application Insights component on which the WebTest operates. Changing this forces a new resource to be created."
  type        = string
}

variable "global_settings" {
  description = "Global settings object when the resource is deploye in landing zones context."
  default     = null
  type        = any
}

variable "base_tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
  default     = {}
}

variable "settings" {
  description = <<DESCRIPTION
Settings for a Standard WebTest (`Microsoft.Insights/webtests@2022-06-15`).

Required:
  - request_url - (string) Absolute URL the test calls. Maps to `Request.RequestUrl`.
  - geo_locations - (list(string)) Azure test location ids (for example
    `emea-nl-ams-azr`). Each entry becomes a `Locations[*].Id` entry.

Optional:
  - description - (string) Free-form description. Defaults to `""`.
  - enabled - (bool) Whether the test runs. Defaults to `true`.
  - frequency - (number) Seconds between runs. Standard WebTests accept only
    `300`, `600` and `900`. Defaults to `300`.
  - timeout - (number) Seconds before a single run is considered failed.
    Defaults to `30`.
  - retry_enabled - (bool) Retry once on failure before alerting. Defaults to `true`.
  - request_headers - (list(object)) ARM `HeaderField` entries, each with the
    lowercase ARM attributes `key` and `value`. Defaults to null (no headers).
  - http_verb - (string) HTTP verb sent by the test. ARM types this as a
    free-form string; the portal uses `GET` and `POST`. Defaults to `GET`.
  - request_body - (string) Base64 encoded request body. Defaults to null.
  - follow_redirects - (bool) Follow HTTP redirects. Defaults to null, leaving
    the service default in place.
  - parse_dependent_requests - (bool) Also load dependent requests such as
    images and scripts. Defaults to `false`.
  - expected_http_status_code - (number) Status code treated as success.
    Defaults to `200`.
  - ignore_http_status_code - (bool) Ignore the returned status code entirely.
    Defaults to null (the status code is evaluated).
  - content_validation - (object) Response body check, using the ARM attribute
    names:
      - ContentMatch - (string, required) Text that must be present or absent.
      - IgnoreCase - (bool) Case-insensitive match. Defaults to null.
      - PassIfTextFound - (bool) `true` passes when the text is found, `false`
        passes when it is absent. Defaults to null.
  - ssl_check_enabled - (bool) Validate the TLS certificate. Defaults to `false`.
  - ssl_cert_remaining_lifetime_check - (number) Fail when the certificate
    expires in fewer than this many days. Requires `ssl_check_enabled = true`
    and a positive value. Defaults to null.
  - configuration - (object) Optional raw WebTest definition:
      - web_test - (string) XML WebTest document sent as `Configuration.WebTest`.
  - tags - (map(string)) Additional resource tags merged over the inherited tags.
  - timeouts - (object) Terraform CRUD timeouts (`create`, `read`, `update`,
    `delete`). Defaults to null, which uses the provider defaults.
DESCRIPTION
  type = object({
    request_url   = string
    geo_locations = list(string)
    description   = optional(string, "")
    enabled       = optional(bool, true)
    frequency     = optional(number, 300)
    timeout       = optional(number, 30)
    retry_enabled = optional(bool, true)
    request_headers = optional(list(object({
      key   = string
      value = string
    })))
    http_verb                 = optional(string, "GET")
    request_body              = optional(string)
    follow_redirects          = optional(bool)
    parse_dependent_requests  = optional(bool, false)
    expected_http_status_code = optional(number, 200)
    ignore_http_status_code   = optional(bool)
    content_validation = optional(object({
      ContentMatch    = string
      IgnoreCase      = optional(bool)
      PassIfTextFound = optional(bool)
    }))
    ssl_check_enabled                 = optional(bool, false)
    ssl_cert_remaining_lifetime_check = optional(number)
    configuration = optional(object({
      web_test = optional(string)
    }))
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition     = contains([300, 600, 900], var.settings.frequency)
    error_message = "Standard WebTest frequency must be 300, 600 or 900 seconds."
  }

  validation {
    condition     = var.settings.ssl_cert_remaining_lifetime_check == null ? true : var.settings.ssl_check_enabled && var.settings.ssl_cert_remaining_lifetime_check > 0
    error_message = "Certificate lifetime checks require SSL checking and a positive number of days."
  }
}