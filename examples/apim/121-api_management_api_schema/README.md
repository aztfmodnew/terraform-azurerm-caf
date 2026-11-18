# Simple API schema

Deploys a resource group, Developer APIM service, API and OpenAPI components
schema in one configuration. Every dependency uses a local CAF key reference;
no remote state or literal ARM IDs are required. Random naming suffixes keep
service names unique. Exactly one schema payload (`components`) is provided.

After parent/root integration, run from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/121-api_management_api_schema/configuration.tfvars
```

Review before applying with the same variable file. Verify the schema's
identifier, content type and Order component in APIM. For cleanup, review
`terraform -chdir=examples destroy` with the same `-var-file`; policies that
reference this schema must be considered before removal. Cleanup deletes the
managed API, APIM service and resource group too; Developer APIM incurs charges.

The [module README](../../../modules/apim/api_management_api_schema/README.md)
provides a plan-only mock contract. It does not validate APIM schema parsing.
