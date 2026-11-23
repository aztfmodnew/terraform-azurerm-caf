# Simple standalone workspace gateway

Creates a resource group, VNet, dedicated /24 delegated subnet and
WorkspaceGatewayPremium standalone gateway using local CAF keys. No remote
state, hardcoded ARM IDs or pre-existing network resources are required.
Confirm regional availability and SKU quota before deployment.
This is not a self-hosted gateway; no APIM workspace binding is provisioned.

The exact AzureCAF standalone-gateway type is absent from public definitions;
the module uses the compatible `azurerm_api_management` naming rule. This example
uses generated CAF names with a five-character suffix for uniqueness.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/147-api_management_standalone_gateway/configuration.tfvars
```

Review charges/network settings before applying with the same file. Verify
gateway provisioning, SKU and subnet in Azure. For cleanup, review and execute
`destroy` with the same file; this removes the managed group and network too.
Remove downstream workspace bindings before deletion.

See the [plan-only mock contract](../../../modules/apim/api_management_standalone_gateway/README.md);
it does not verify regional capacity or subnet suitability.
