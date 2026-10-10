# API Management (apim)

This module is part of the Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate it directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.30.0"
  apim = var.apim
  # You can add other objects as needed, e.g. resource_groups = var.resource_groups
}
```

The CAF Terraform module is iterative by default; you can instantiate as many objects as needed using the following structure:

```hcl
resource_to_be_created = {
  object1 = {
    # configuration details
  }
  object2 = {
    # configuration details
  }
}
```

You can review the complete set of examples in the [GitHub repository](https://github.com/aztfmodnew/terraform-azurerm-caf/tree/main/examples/apim).

## API Management service options

The `api_management` service configuration supports the AzureRM resource
options for regional deployments, certificates, delegation, managed identity,
hostnames, protocols, security, sign-in/sign-up, tenant access, virtual
networking, public network access, tags, and create/read/update/delete
timeouts. Optional regional locations and certificates can be supplied as
maps using `additional_locations` and `certificates`. The legacy singular
`additional_location` and `certificate` forms remain supported.

The resource accepts both current AzureRM names and existing CAF aliases for
HTTP/2, security settings, and Key Vault certificate IDs. In security
configuration, current AzureRM argument names take precedence over `enable_*`
and the historical, inverted `disable_*` aliases; for backward compatibility,
the latter values map directly to the provider's `*_enabled` arguments. The
documented `tls_ecdheRsa_*` spellings are retained as aliases for
`tls_ecdhe_rsa_*`. If both hostname certificate ID names are set,
`key_vault_certificate_id` takes precedence.
Terms of service should be configured under `sign_up.terms_of_service`; the
previous top-level `terms_of_service` form remains accepted as a fallback.

For regional subnet references, use the `virtual_network_configuration` block
within the relevant location and provide either `subnet_id` directly or the
CAF `vnet_key`/`subnet_key` reference. The top-level
`public_network_access_enabled` setting controls management-plane access; Azure
requires public access to be enabled when the service is initially created.
Omitted or null public-access and virtual-network settings default to `true`
and `None`. Omitted delegation flags remain null at the module boundary; the
AzureRM provider documents disabled defaults for those flags.

The focused, plan-only module contract checks legacy aliases and the added
provider options without changing the shared mock runner or CI workflows:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management -no-color
```

The contract verifies Terraform's planned configuration only; it does not
confirm service-side acceptance or deploy resources.

## API Management API options

The `api_management_api` settings support `api_type` (`graphql`, `http`,
`soap`, or `websocket`), contact and license blocks, OAuth2 and OpenID
authentication, the terms-of-service URL, subscription-key parameter names,
and create/read/update/delete timeouts. API type defaults to `http` and
subscription keys are required by default. A version requires a version set;
websocket APIs require `service_url`. Without `source_api_id`, configure
`display_name`, `path`, and `protocols`. A supplied display name must not be
empty; an empty path is valid for a root API. OAuth2 and OpenID authentication are
mutually exclusive. The existing API import remains supported; `wsdl_selector`
is limited to `wsdl` and `wsdl-link` imports.

The focused API contract checks the new fields, module defaults, each
cross-field/allowed-value validation, and the valid empty path for a root API
using a plan-only mock. Both `header` and `query` are required when
`subscription_key_parameter_names` is supplied, matching the
[provider contract](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api).
Tests do not validate imported document contents, real provider defaulting or
Azure-side acceptance:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api -no-color
```

## API Management API diagnostic options

API diagnostic settings support all four request/response directions, logging
verbosity and sampling, correlation protocol, client IP logging, operation
name format, and create/read/update/delete timeouts. Optional `data_masking`
belongs inside the selected request or response block and can mask or hide
query parameters and mask headers. The focused contract verifies this nested
shape without changing shared runners or pipelines:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_diagnostic
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_diagnostic -no-color
```

## API Management service diagnostic options

Service diagnostics accept `applicationinsights` or `azuremonitor` identifiers,
all four frontend/backend request/response logging blocks, and create/read/
update/delete timeouts. Each direction supports body-byte limits, header
selection, and nested `data_masking`; query parameters accept `Mask` or `Hide`,
while headers support `Mask`. The module validates sampling percentages from
0 through 100, body-byte limits up to 8192, and the documented protocol,
verbosity, operation-name, and masking values.

The plan-only contract verifies full nested masking, Azure Monitor selection,
timeouts, and rejection of a payload limit above the provider maximum:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_diagnostic
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_diagnostic -no-color
```

## API Management gateway options

Gateways require a CAF-generated name, an API Management service reference,
and `location_data.name`; the location block also accepts city, district, and
region. The optional description and all four create/read/update/delete
timeouts are supported. The service reference accepts a local or remote key,
or a direct ID; existing keyed references continue to take precedence over a
simultaneously supplied direct ID.

The focused plan-only contract checks CAF naming, location fields, local and
remote references, direct-ID compatibility, key-reference precedence, and
timeouts:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_gateway
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_gateway -no-color
```

## API Management gateway API options

Gateway API associations require both an API Management gateway reference and
an API reference. Each accepts a direct ID or local/remote key; keyed references
retain precedence over direct IDs, and each reference resolves its own landing
zone. The supported create/read/delete timeouts are configurable; AzureRM does
not support an update timeout for this immutable association resource.

The focused plan-only contract verifies direct IDs, local and remote key
resolution, null landing-zone fallback, keyed-reference precedence, and the
three supported timeouts:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_gateway_api
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_gateway_api -no-color
```

## API Management group options

Groups support all AzureRM arguments: required display name, description,
external directory ID, type (`custom`, `external`, or `system`), and all four
timeouts. The provider default group type is retained when `type` is omitted.
API Management and resource-group dependencies accept direct names or
local/remote keys; the legacy `resource_group_key` remains a fallback.

The focused plan-only contract checks provider options, CAF naming,
local/remote/direct references, the legacy resource-group key, provider
defaults, and invalid-type rejection:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_group
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_group -no-color
```

## API Management logger options

Loggers support buffered publishing, description, the portal-linked resource
ID, and all four timeouts. Application Insights accepts a local/remote
reference or direct instrumentation key/connection string. Use
`identity_client_id` with a connection-string source for managed-identity
ingestion; the legacy instrumentation-key mode remains supported. Configure
either Application Insights or Event Hubs as the logger destination, not both.
Event Hubs supports connection strings or endpoint URI with a user-assigned
identity client ID. Prefer endpoint URI and managed identity to avoid shared
keys.

The focused plan-only contract checks source selection, local App Insights
resolution, linked resource ID resolution, Event Hubs authentication options,
eventhub-only loggers, timeouts, and invalid source combinations:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_logger
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_logger -no-color
```

## API Management product options

Products support all AzureRM product arguments and four configurable
timeouts. `subscription_required` retains the provider default of `true`;
`approval_required` and `subscriptions_limit` are only valid when subscriptions
are required. An optional product policy can use inline XML, the legacy
configuration-directory-relative `xml_file`, or a publicly reachable `xml_link`.
When both `xml_file` and `xml_content` are provided, the file continues to take
precedence. A policy has its own four independent timeouts.

The focused plan-only contract checks provider defaults, product and policy
options, XML source selection, legacy file precedence, timeout handling, and
invalid combinations:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_product
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_product -no-color
```

The existing example exercises the integrated product, policy, and subscription
configuration with the shared mock runner:

```bash
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/117-api_management_product/configuration.tfvars -no-color
```

## API Management subscription options

Subscriptions support API or product scope, a user association, caller-supplied
primary/secondary keys, a subscription identifier, tracing, state, and all
four AzureRM timeouts. Product and API scopes are mutually exclusive; omitting
both retains the provider's all-APIs scope. The defaults remain `submitted`
for state and `true` for tracing.

The focused plan-only contract checks product and API scopes, user and key
settings, provider defaults, timeout handling, and invalid state/scope
combinations:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_subscription
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_subscription -no-color
```

The dedicated example covers the all-APIs subscription form with the shared
mock runner:

```bash
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/116-api_management_subscription/configuration.tfvars -no-color
```

## API Management user options

Users support the required identifier, email, first and last names, optional
confirmation mode, note, password, state, and all four AzureRM timeouts. The
password is sensitive in the provider. Confirmation accepts `invite` or
`signup`; state accepts `active`, `blocked`, or `pending`. Azure only permits
pending users to transition to active or blocked.

The focused plan-only contract checks optional settings, password sensitivity,
timeouts, and invalid enum values:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_user
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_user -no-color
```

The existing user example is checked with the shared mock runner:

```bash
terraform -chdir=examples test -test-directory=tests/mock -var-file=apim/108-api_management_user/configuration.tfvars -no-color
```

## API Management API operation options

API operation settings support request definitions, multiple response
definitions, headers, query parameters, representations, form parameters,
examples, template parameters, and all four operation timeouts. Request and
response collections use maps with stable keys. Any HTTP method supported by
API Management is accepted; template parameters should be provided when the
URL template includes placeholders. Form parameters are required for
URL-encoded and multipart representations. The focused contract exercises the
nested request/response blocks and verifies a nonstandard HTTP method:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_operation
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_operation -no-color
```

## API Management API operation policy options

API operation policies support `xml_content` or a publicly accessible
`xml_link`, references to an API operation by its logical `operation_id` or by
a local/remote landing-zone key, and all four create/read/update/delete
timeouts. Do not pass the operation's ARM resource ID where the provider
expects its logical identifier. Key references resolve this value through the
operation module output. The focused plan-only contract checks both XML input
forms and operation reference resolution without changing shared mocks or CI
workflows:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_operation_policy
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_operation_policy -no-color
```

This contract verifies Terraform's planned resource configuration only; it
does not confirm Azure-side acceptance or deploy resources.

## API Management API operation tag options

API operation tags require a CAF-generated `name`, a `display_name`, and an API
operation reference. The module exposes all four provider timeouts. Its
plan-only contract checks the required resource arguments, generated name, and
timeouts without changing shared mocks or CI workflows:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_operation_tag
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_operation_tag -no-color
```

This contract verifies Terraform's planned resource configuration only; it
does not confirm Azure-side acceptance or deploy resources.

## API Management API policy options

API policies support either XML content or a publicly accessible XML link, and
all four create/read/update/delete provider timeouts. The focused plan-only
contract checks both XML forms and timeout passthrough without changing shared
mocks or CI workflows:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_api_policy
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_api_policy -no-color
```

This contract verifies Terraform's planned resource configuration only; it
does not confirm Azure-side acceptance or deploy resources.

## API Management backend options

Backends support credentials and authorization, proxy and TLS settings,
Service Fabric cluster certificates and nested server X.509 names, circuit
breaker failure conditions, and all four provider timeouts. Circuit breaker
settings validate the required count-or-percentage and failure criteria, while
Service Fabric settings require a client certificate reference. The historical
top-level `server_x509_name` setting remains supported; new configurations
should use `service_fabric_cluster.server_x509_name`. The focused plan-only
contract exercises these nested blocks and compatibility:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_backend
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_backend -no-color
```

This contract verifies Terraform's planned resource configuration only; it
does not confirm Azure-side acceptance or deploy resources.

## API Management certificate options

Certificates accept either base64-encoded PFX `data` or a Key Vault secret
reference, but not both. Key Vault certificates and certificate requests can be
resolved by local or remote landing-zone key; the module also accepts direct
secret IDs and preserves the legacy `key_vault_id` alias. A user-assigned
identity can be resolved by key or supplied by client ID. PFX passwords and
all four provider timeouts are supported. The focused plan-only contract tests
both certificate source paths, Key Vault identity resolution, source
exclusivity, and timeouts:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_certificate
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_certificate -no-color
```

The shared mock plan for the deployment example requires both input files:

```bash
terraform -chdir=examples test -test-directory=tests/mock -var-file=./apim/111-api_management_certificate/configuration.tfvars -var-file=./apim/111-api_management_certificate/certificates.tfvars -no-color
```

This contract verifies Terraform's planned resource configuration only; it
does not verify the PFX payload, Key Vault access, Azure-side acceptance, or
deploy resources.

## API Management custom-domain options

Custom domains support all five AzureRM endpoint blocks:
`developer_portal`, `management`, `portal`, `gateway`, and `scm`. Singular
settings configure one endpoint; plural forms accept maps for repeated blocks.
The legacy `gateways` input accepts either a map or list, and `proxy` remains
an alias. Endpoints support PFX certificate data/password, direct Key Vault
secret URIs or local/remote certificate references, managed-identity
resolution, client-certificate negotiation, and provider timeouts.
`default_ssl_binding` is supported for gateways only.

The focused compatibility contract checks legacy input shapes, all endpoint
blocks, certificate and identity resolution, repeated endpoints, and timeouts:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/unit/apim/api_management_custom_domain
terraform -chdir=examples test -test-directory=tests/unit/apim/api_management_custom_domain -no-color
```

This plan-only test does not verify Azure-side acceptance or deploy resources.

---

## Inputs

| Name                          | Description                                                                                                                                                                                                                                                                                                                                    | Type   | Required |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | :------: |
| name                          | The name of the API Management Service. Changing this forces a new resource to be created.                                                                                                                                                                                                                                                     |        |   True   |
| region                        | The region_key where the resource will be deployed                                                                                                                                                                                                                                                                                             | String |   True   |
| resource_group                | The `resource_group` block as defined below.                                                                                                                                                                                                                                                                                                   | Block  |   True   |
| publisher_name                | The name of publisher/company.                                                                                                                                                                                                                                                                                                                 |        |   True   |
| publisher_email               | The email of publisher/company.                                                                                                                                                                                                                                                                                                                |        |   True   |
| sku_name                      | A supported tier (`Consumption`, `Developer`, `Basic`, `BasicV2`, `Standard`, `StandardV2`, `Premium`, or `PremiumV2`) and positive capacity separated by an underscore, for example `Developer_1`. Consumption capacity should be zero. |        |   True   |
| additional_location           | One or more `additional_location` blocks as defined below.                                                                                                                                                                                                                                                                                     | Block  |  False   |
| additional_locations          | Map of additional regional locations, each with location, capacity, zones, public IP, gateway, and virtual network settings.                                                                                                                                                                                                                   | Map    |  False   |
| certificate                   | One or more (up to 10) `certificate` blocks as defined below.                                                                                                                                                                                                                                                                                  | Block  |  False   |
| certificates                  | Map of certificates to configure on the service.                                                                                                                                                                                                                                                                                              | Map    |  False   |
| client_certificate_enabled    | Enforce a client certificate to be presented on each request to the gateway? This is only supported when sku type is `Consumption`.                                                                                                                                                                                                            |        |  False   |
| delegation                    | A `delegation` block as defined below.                                                                                                                                                                                                                                                                                                         | Block  |  False   |
| gateway_disabled              | Disable the gateway in main region? This is only supported when `additional_location` is set.                                                                                                                                                                                                                                                  |        |  False   |
| min_api_version               | The version which the control plane API calls to API Management service are limited with version equal to or newer than.                                                                                                                                                                                                                       |        |  False   |
| zones                         | A list of availability zones.                                                                                                                                                                                                                                                                                                                  |        |  False   |
| identity                      | An `identity` block as defined below.                                                                                                                                                                                                                                                                                                          | Block  |  False   |
| hostname_configuration        | A `hostname_configuration` block as defined below.                                                                                                                                                                                                                                                                                             | Block  |  False   |
| notification_sender_email     | Email address from which the notification will be sent.                                                                                                                                                                                                                                                                                        |        |  False   |
| policy                        | A `policy` block as defined below.                                                                                                                                                                                                                                                                                                             | Block  |  False   |
| protocols                     | A `protocols` block as defined below.                                                                                                                                                                                                                                                                                                          | Block  |  False   |
| security                      | A `security` block as defined below.                                                                                                                                                                                                                                                                                                           | Block  |  False   |
| sign_in                       | A `sign_in` block as defined below.                                                                                                                                                                                                                                                                                                            | Block  |  False   |
| sign_up                       | A `sign_up` block as defined below.                                                                                                                                                                                                                                                                                                            | Block  |  False   |
| tenant_access                 | A `tenant_access` block as defined below.                                                                                                                                                                                                                                                                                                      | Block  |  False   |
| public_ip_address_id          | ID of a standard SKU IPv4 public IP address.                                                                                                                                                                                                                                                                                                  | String |  False   |
| public_network_access_enabled | Whether public management-plane access is enabled. Defaults to `true`; it must be `true` during creation.                                                                                                                                                                                                                                       | Bool   |  False   |
| virtual_network_type          | The type of virtual network you want to use, valid values include: `None`, `External`, `Internal`.                                                                                                                                                                                                                                             |        |  False   |
| virtual_network_configuration | A `virtual_network_configuration` block as defined below. Required when `virtual_network_type` is `External` or `Internal`.                                                                                                                                                                                                                    | Block  |  False   |
| tags                          | A mapping of tags assigned to the resource.                                                                                                                                                                                                                                                                                                    |        |  False   |
| timeouts                      | Optional create, read, update, and delete operation timeouts.                                                                                                                                                                                                                                                                                 | Block  |  False   |

## Blocks

| Block                         | Argument                                            | Description                                                                                                                                                                                                     | Required |
| ----------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| resource_group                | key                                                 | Key for resource_group                                                                                                                                                                                          |          |
| resource_group                | lz_key                                              | Landing Zone Key in which the resource_group is located                                                                                                                                                         | True     |
| resource_group                | name                                                | The name of the resource_group                                                                                                                                                                                  | True     |
| additional_location           | location                                            | The name of the Azure Region in which the API Management Service should be expanded to.                                                                                                                         | True     |
| additional_location           | capacity                                            | Number of compute units for this region; defaults to the main region capacity.                                                                                                                                  | False    |
| additional_location           | zones                                               | Availability zones for this regional instance.                                                                                                                                                                   | False    |
| additional_location           | public_ip_address_id                               | Standard SKU IPv4 public IP ID for this regional instance.                                                                                                                                                       | False    |
| additional_location           | gateway_disabled                                   | Whether the gateway is disabled in this additional region.                                                                                                                                                      | False    |
| additional_location           | virtual_network_configuration                       | A `virtual_network_configuration` block as defined below. Required when `virtual_network_type` is `External` or `Internal`.                                                                                     | False    |
| virtual_network_configuration | subnet_id                                           | The id of the subnet that will be used for the API Management.                                                                                                                                                  | True     |
| certificate                   | encoded_certificate                                 | The Base64 Encoded PFX or Base64 Encoded X.509 Certificate.                                                                                                                                                     | True     |
| certificate                   | store_name                                          | The name of the Certificate Store where this certificate should be stored. Possible values are `CertificateAuthority` and `Root`.                                                                               | True     |
| certificate                   | certificate_password                                | The password for the certificate.                                                                                                                                                                               | False    |
| identity                      | type                                                | Specifies the type of Managed Service Identity that should be configured on this API Management Service. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | True     |
| identity                      | identity_ids                                        | A list of IDs for User Assigned Managed Identity resources to be assigned.                                                                                                                                      | False    |
| hostname_configuration        | management                                          | One or more `management` blocks as documented below.                                                                                                                                                            | False    |
| hostname_configuration        | portal                                              | One or more `portal` blocks as documented below.                                                                                                                                                                | False    |
| hostname_configuration        | developer_portal                                    | One or more `developer_portal` blocks as documented below.                                                                                                                                                      | False    |
| hostname_configuration        | proxy                                               | One or more `proxy` blocks as documented below.                                                                                                                                                                 | False    |
| proxy                         | default_ssl_binding                                 | Is the certificate associated with this Hostname the Default SSL Certificate? This is used when an SNI header isn't specified by a client. Defaults to `false`.                                                 | False    |
| proxy                         | host_name                                           | The Hostname to use for the Management API.                                                                                                                                                                     | True     |
| proxy                         | key_vault_id                                        | The ID of the Key Vault Secret containing the SSL Certificate, which must be should be of the type `application/x-pkcs12`.                                                                                      | False    |
| proxy                         | certificate                                         | The Base64 Encoded Certificate.                                                                                                                                                                                 | False    |
| certificate                   | encoded_certificate                                 | The Base64 Encoded PFX or Base64 Encoded X.509 Certificate.                                                                                                                                                     | True     |
| certificate                   | store_name                                          | The name of the Certificate Store where this certificate should be stored. Possible values are `CertificateAuthority` and `Root`.                                                                               | True     |
| certificate                   | certificate_password                                | The password for the certificate.                                                                                                                                                                               | False    |
| proxy                         | certificate_password                                | The password associated with the certificate provided above.                                                                                                                                                    | False    |
| proxy                         | negotiate_client_certificate                        | Should Client Certificate Negotiation be enabled for this Hostname? Defaults to `false`.                                                                                                                        | False    |
| hostname_configuration        | scm                                                 | One or more `scm` blocks as documented below.                                                                                                                                                                   | False    |
| policy                        | xml_content                                         | The XML Content for this Policy.                                                                                                                                                                                | False    |
| policy                        | xml_link                                            | A link to an API Management Policy XML Document, which must be publicly available.                                                                                                                              | False    |
| protocols                     | enable_http2                                        | Should HTTP/2 be supported by the API Management Service? Defaults to `false`.                                                                                                                                  | False    |
| security                      | enable_backend_ssl30                                | Should SSL 3.0 be enabled on the backend of the gateway? Defaults to `false`.                                                                                                                                   | False    |
| security                      | enable_backend_tls10                                | Should TLS 1.0 be enabled on the backend of the gateway? Defaults to `false`.                                                                                                                                   | False    |
| security                      | enable_backend_tls11                                | Should TLS 1.1 be enabled on the backend of the gateway? Defaults to `false`.                                                                                                                                   | False    |
| security                      | enable_frontend_ssl30                               | Should SSL 3.0 be enabled on the frontend of the gateway? Defaults to `false`.                                                                                                                                  | False    |
| security                      | enable_frontend_tls10                               | Should TLS 1.0 be enabled on the frontend of the gateway? Defaults to `false`.                                                                                                                                  | False    |
| security                      | enable_frontend_tls11                               | Should TLS 1.1 be enabled on the frontend of the gateway? Defaults to `false`.                                                                                                                                  | False    |
| security                      | tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled | Should the `TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA` cipher be enabled? Defaults to `false`.                                                                                                                       | False    |
| security                      | tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled | Should the `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA` cipher be enabled? Defaults to `false`.                                                                                                                       | False    |
| security                      | tls_ecdheRsa_with_aes128_cbc_sha_ciphers_enabled    | Should the `TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA` cipher be enabled? Defaults to `false`.                                                                                                                         | False    |
| security                      | tls_ecdheRsa_with_aes256_cbc_sha_ciphers_enabled    | Should the `TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA` cipher be enabled? Defaults to `false`.                                                                                                                         | False    |
| security                      | tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      | Should the `TLS_RSA_WITH_AES_128_CBC_SHA256` cipher be enabled? Defaults to `false`.                                                                                                                            | False    |
| security                      | tls_rsa_with_aes128_cbc_sha_ciphers_enabled         | Should the `TLS_RSA_WITH_AES_128_CBC_SHA` cipher be enabled? Defaults to `false`.                                                                                                                               | False    |
| security                      | tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      | Should the `TLS_RSA_WITH_AES_128_GCM_SHA256` cipher be enabled? Defaults to `false`.                                                                                                                            | False    |
| security                      | tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      | Should the `TLS_RSA_WITH_AES_256_CBC_SHA256` cipher be enabled? Defaults to `false`.                                                                                                                            | False    |
| security                      | tls_rsa_with_aes256_cbc_sha_ciphers_enabled         | Should the `TLS_RSA_WITH_AES_256_CBC_SHA` cipher be enabled? Defaults to `false`.                                                                                                                               | False    |
| security                      | enable_triple_des_ciphers                           | Should the `TLS_RSA_WITH_3DES_EDE_CBC_SHA` cipher be enabled for all TLS versions (1.0, 1.1 and 1.2)? Defaults to `false`.                                                                                      | False    |
| security                      | triple_des_ciphers_enabled                          | Should the `TLS_RSA_WITH_3DES_EDE_CBC_SHA` cipher be enabled for all TLS versions (1.0, 1.1 and 1.2)? Defaults to `false`.                                                                                      | False    |
| security                      | disable_backend_ssl30                               | Should SSL 3.0 be disabled on the backend of the gateway? This property was mistakenly inverted and `true` actually enables it. Defaults to `false`.                                                            | False    |
| security                      | disable_backend_tls10                               | Should TLS 1.0 be disabled on the backend of the gateway? This property was mistakenly inverted and `true` actually enables it. Defaults to `false`.                                                            | False    |
| security                      | disable_backend_tls11                               | Should TLS 1.1 be disabled on the backend of the gateway? This property was mistakenly inverted and `true` actually enables it. Defaults to `false`.                                                            | False    |
| security                      | disable_frontend_ssl30                              | Should SSL 3.0 be disabled on the frontend of the gateway? This property was mistakenly inverted and `true` actually enables it. Defaults to `false`.                                                           | False    |
| security                      | disable_frontend_tls10                              | Should TLS 1.0 be disabled on the frontend of the gateway? This property was mistakenly inverted and `true` actually enables it. Defaults to `false`.                                                           | False    |
| security                      | disable_frontend_tls11                              | Should TLS 1.1 be disabled on the frontend of the gateway? This property was mistakenly inverted and `true` actually enables it. Defaults to `false`.                                                           | False    |
| sign_in                       | enabled                                             | Should anonymous users be redirected to the sign in page?                                                                                                                                                       | True     |
| sign_up                       | enabled                                             | Can users sign up on the development portal?                                                                                                                                                                    | True     |
| sign_up                       | terms_of_service                                    | A `terms_of_service` block as defined below.                                                                                                                                                                    | True     |
| terms_of_service              | consent_required                                    | Should the user be asked for consent during sign up?                                                                                                                                                            | True     |
| terms_of_service              | enabled                                             | Should Terms of Service be displayed during sign up?                                                                                                                                                            | True     |
| terms_of_service              | text                                                | The Terms of Service which users are required to agree to in order to sign up.                                                                                                                                  | True     |
| tenant_access                 | enabled                                             | Should the access to the management api be enabled?                                                                                                                                                             | True     |
| virtual_network_configuration | subnet_id                                           | The id of the subnet that will be used for the API Management.                                                                                                                                                  | True     |

## Outputs

| Name                 | Description                                                                                        |
| -------------------- | -------------------------------------------------------------------------------------------------- | --- | --- |
| id                   | The ID of the API Management Service.                                                              |     |     |
| additional_location  | Zero or more `additional_location` blocks as documented below.                                     |     |     |
| gateway_url          | The URL of the Gateway for the API Management Service.                                             |     |     |
| gateway_regional_url | The Region URL for the Gateway of the API Management Service.                                      |     |     |
| identity             | An `identity` block as defined below.                                                              |     |     |
| management_api_url   | The URL for the Management API associated with this API Management service.                        |     |     |
| portal_url           | The URL for the Publisher Portal associated with this API Management service.                      |     |     |
| developer_portal_url | The URL for the Developer Portal associated with this API Management service.                      |     |     |
| public_ip_addresses  | The Public IP addresses of the API Management Service.                                             |     |     |
| private_ip_addresses | The Private IP addresses of the API Management Service.                                            |     |     |
| scm_url              | The URL for the SCM (Source Code Management) Endpoint associated with this API Management service. |     |     |
| tenant_access        | The `tenant_access` block as documented below.                                                     |     |     |
