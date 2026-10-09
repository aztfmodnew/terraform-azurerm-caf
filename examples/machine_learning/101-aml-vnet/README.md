# Azure Machine Learning workspace with private access

This example configures a Machine Learning workspace with public network access
disabled, a workspace private endpoint, and the workspace Private Link DNS
zones from the [Azure Private Endpoint DNS
configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns).
It uses the existing shared example-plan runner; it does not deploy resources.

The scenario consists of two complementary variable files. Load them in this
order:

1. `configuration.tfvars` — workspace, resource group, and dependent services.
2. `networking_spoke.tfvars` — VNet, subnet, NSG rules, and private DNS zones.

From the repository root, validate the scenario with:

```sh
terraform -chdir=examples init -backend=false
terraform -chdir=examples test \
  -test-directory=./tests/mock \
  -var-file=./machine_learning/101-aml-vnet/configuration.tfvars \
  -var-file=./machine_learning/101-aml-vnet/networking_spoke.tfvars \
  -verbose
```

The mock plan checks Terraform configuration and CAF dependency wiring only.
It does not verify Azure-side private endpoint approval, DNS resolution, or
Machine Learning service acceptance.
