# Simple Application Gateway

This example configures a WAF v2 Application Gateway with public and private
frontends, HTTP/2, a WAF policy, and a private DNS A record for its private
frontend IP. The private DNS zone is linked to the example VNet.

The configuration is split across three variable files:

- `configuration.tfvars`: global settings, resource group, DNS zone and VNet.
- `application.tfvars`: Application Gateway application configuration.
- `network_security_group_definition.tfvars`: subnet NSG rules.

Run the repository mock plan from the repository root:

```bash
terraform -chdir=./examples test -test-directory=./tests/mock \
  -var-file=../examples/networking/app_gateway/100-simple-app-gateway/configuration.tfvars \
  -var-file=../examples/networking/app_gateway/100-simple-app-gateway/application.tfvars \
  -var-file=../examples/networking/app_gateway/100-simple-app-gateway/network_security_group_definition.tfvars \
  -verbose
```
