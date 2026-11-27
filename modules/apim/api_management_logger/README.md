module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.26.1"
}

# api_management_logger

## Inputs
| Name | Description | Type | Required |
|------|-------------|------|:--------:|
|name| The name of this Logger, which must be unique within the API Management Service. Changing this forces a new resource to be created.||True|
|resource_group|The `resource_group` block as defined below.|Block|True|
|api_management|The `api_management` block as defined below.|Block|True|
|application_insights| An `application_insights` block as documented below.| Block |False|
|buffered| Specifies whether records should be buffered in the Logger prior to publishing. Defaults to `true`.||False|
|description| A description of this Logger.||False|
|eventhub| An `eventhub` block as documented below.| Block |False|
|resource_id| The target resource id which will be linked in the API-Management portal page.||False|

## Blocks
| Block | Argument | Description | Required |
|-------|----------|-------------|----------|
|resource_group| key | Key for  resource_group||| Required if  |
|resource_group| lz_key |Landing Zone Key in wich the resource_group is located|||True|
|resource_group| name | The name of the resource_group |||True|
|api_management| key | Key for  api_management||| Required if  |
|api_management| lz_key |Landing Zone Key in wich the api_management is located|||True|
|api_management| name | The name of the api_management |||True|
|application_insights|instrumentation_key| The instrumentation key used to push data to Application Insights.|||True|
|eventhub|name| Direct Event Hub name. A direct name or an `event_hub`/`hub` reference is required.|||False|
|eventhub|connection_string| Direct authorization-rule connection string. Direct values take precedence over resolved authorization rules.|||False|
|eventhub|endpoint_uri| Direct namespace endpoint for managed-identity ingestion. A namespace reference can provide it; otherwise the module derives its host with the configured cloud `servicebusEndpoint`.|||False|
|eventhub|event_hub| Event Hub key/name reference resolved through CAF combined objects.|||False|
|eventhub|event_hub_namespace| Event Hub Namespace key/name reference resolved through CAF combined objects.|||False|
|eventhub|authorization_rule| Event Hub or namespace authorization-rule reference providing a connection string.|||False|
|eventhub|managed_identity| User-assigned managed identity reference providing the APIM logger client ID.|||False|

Exactly one of `application_insights` and `eventhub` is accepted. No generic
Azure Monitor logger is synthesized. Event Hub ingestion supports either a
connection string or a namespace endpoint with the service identity; direct
inputs retain precedence for compatibility. Derived endpoints use
`cloud.servicebusEndpoint`, defaulting to `.servicebus.windows.net`, so
sovereign-cloud consumers can override the Service Bus DNS suffix.

## Focused contract

```bash
terraform -chdir=examples test \
  -test-directory=tests/unit/apim/api_management_logger \
  -no-color
```

## Outputs
| Name | Description |
|------|-------------|
|id|The ID of the API Management Logger.|||
