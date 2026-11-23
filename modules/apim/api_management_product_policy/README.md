# API Management product policy

Manages a product-scope policy independently of product creation, including
policies on products in remote state or looked up through `data_sources`.
Supply either `xml_content` or `xml_link`. Product references resolve the logical
`product_id`, not the product ARM ID. Never manage the same policy using both
this collection and the product module's embedded policy configuration.

Schema validated against the AzureRM
[product policy documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_product_policy).
All writable arguments and create/read/update/delete timeouts are supported.

The [self-contained example](../../../examples/apim/144-api_management_product_policy/configuration.tfvars)
creates a service, product and independent policy using key-based references.

From `examples/`, run the isolated plan-only contract:

```sh
terraform init -backend=false -test-directory=tests/unit/apim/api_management_product_policy
terraform test -test-directory=tests/unit/apim/api_management_product_policy
```
