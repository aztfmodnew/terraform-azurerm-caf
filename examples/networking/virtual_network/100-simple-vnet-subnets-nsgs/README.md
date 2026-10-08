# Virtual network, subnets, and NSGs

This multi-file example creates a virtual network with four subnets and
associated network security groups. The web subnet enables the Microsoft
Storage service endpoint.

The configuration is split across:

- `configuration.tfvars`: global settings, resource group, and VNet/subnets.
- `nsg.tfvars`: network security group rules.
- `public-ip-addresses.tfvars`: public IP addresses.
- `routes.tfvars`: route table and route.

Run the repository mock plan from the repository root:

```bash
terraform -chdir=./examples test -test-directory=./tests/mock \
  -var-file=../examples/networking/virtual_network/100-simple-vnet-subnets-nsgs/configuration.tfvars \
  -var-file=../examples/networking/virtual_network/100-simple-vnet-subnets-nsgs/nsg.tfvars \
  -var-file=../examples/networking/virtual_network/100-simple-vnet-subnets-nsgs/public-ip-addresses.tfvars \
  -var-file=../examples/networking/virtual_network/100-simple-vnet-subnets-nsgs/routes.tfvars \
  -verbose
```
