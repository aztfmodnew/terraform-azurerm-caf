# Private Azure Monitor

Deploys a VNet and private-endpoint subnet, a Log Analytics workspace,
workspace-based Application Insights, an Azure Monitor Private Link Scope,
both scoped services, and a private endpoint with the five standard Azure
Monitor private DNS zones.

## Prerequisites

- Terraform 1.6 or newer.
- Azure authentication for a subscription in which the caller can manage
  resource groups, networking, and Azure Monitor resources.
- The `Microsoft.Insights` and `Microsoft.Network` resource providers.

## Deploy

```shell
cd examples
terraform init -backend=false
terraform plan \
  -var-file=monitoring/105-private-monitoring/configuration.tfvars
terraform apply \
  -var-file=monitoring/105-private-monitoring/configuration.tfvars
```

## Validate

Confirm that the scope has both scoped services, its ingestion and query access
modes are `PrivateOnly`, the endpoint uses subresource `azuremonitor`, and all
five DNS zones are in the endpoint's DNS zone group and linked to the VNet.

The CI-safe mock plan is:

```shell
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=monitoring/105-private-monitoring/configuration.tfvars
```

## Cleanup

```shell
terraform destroy \
  -var-file=monitoring/105-private-monitoring/configuration.tfvars
```
