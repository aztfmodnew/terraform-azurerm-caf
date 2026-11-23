# Simple global schema

Creates a resource group, Developer APIM service and reusable JSON schema.
All dependencies use local CAF keys, with no remote state or hardcoded ARM
IDs. Generated schema identifiers should be read from module outputs when
building policies. No pre-existing APIM resources are required.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/129-api_management_global_schema/configuration.tfvars
```

Review and apply with the same file only when approved. Verify schema type,
identifier and contents in APIM. Remove policy references before cleanup;
review and execute `destroy` with the same file. This removes the managed APIM
service and resource group as well. Developer APIM incurs charges until removed.

The [module's plan-only mock contract](../../../modules/apim/api_management_global_schema/README.md)
checks forwarding of XML/JSON values and dependencies, not Azure schema acceptance.
