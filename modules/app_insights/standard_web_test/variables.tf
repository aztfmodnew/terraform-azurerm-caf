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
Standard WebTest settings. request_url and geo_locations are required.
Optional request_headers uses ARM key/value entries; request_body is base64
encoded. content_validation uses ARM ContentMatch, IgnoreCase and PassIfTextFound.
description, enabled, frequency, timeout, retry_enabled, http_verb,
follow_redirects, parse_dependent_requests, expected_http_status_code,
ignore_http_status_code, ssl_check_enabled, ssl_cert_remaining_lifetime_check,
configuration.web_test, tags and CRUD timeouts customize the test.
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