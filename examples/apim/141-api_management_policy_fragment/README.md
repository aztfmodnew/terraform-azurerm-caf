# Simple policy fragment

Creates a resource group, Developer APIM service and reusable header fragment
using local CAF keys. No remote state, literal ARM IDs or pre-existing APIM
resources are required. Use the generated fragment-name output in an outbound
`include-fragment` policy; this example does not modify any policy.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/141-api_management_policy_fragment/configuration.tfvars
```

Review before applying with the same file. Verify the fragment value/format
in APIM; test behavior only after deliberately including it in a policy.
Remove include-fragment references before cleanup, then review and execute
`destroy` with the same file. Cleanup deletes the managed APIM service and
resource group too. Developer APIM incurs charges while deployed.

See the [plan-only mock contract](../../../modules/apim/api_management_policy_fragment/README.md);
it does not execute policies or validate Azure's XML processing.
