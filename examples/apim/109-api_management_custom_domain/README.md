# API Management custom domains

This example uses a self-signed Key Vault certificate for gateway and developer
portal hostnames. Its user-assigned identity is attached to API Management,
granted secret access and selected through each endpoint's `managed_identity`
reference.

Supply both var-files. The configuration defines the resource group, identity,
vault and API Management instance; the certificates file defines the certificate.
No public DNS registration is performed.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/apim/109-api_management_custom_domain/configuration.tfvars \
  -var-file=../examples/apim/109-api_management_custom_domain/certificates.tfvars \
  -verbose
```

`key_vault_certificate_id` accepts a Key Vault secret URI, not a vault ARM ID.
The legacy `key_vault_id` input remains accepted for that URI. Current argument
names take precedence. Use `certificate_key` for certificates and
`certificate_request_key` for certificate requests.

The custom-domain module supports the provider's `developer_portal`,
`management`, `portal`, `gateway`, and `scm` endpoint blocks. Each can be
configured as a singular object; the plural forms accept maps to configure
multiple endpoints. `gateways` and the legacy `proxy` alias accept maps or
lists. Endpoints support PFX certificate data and password, direct Key Vault
secret URIs or local/remote certificate references, client-certificate
negotiation, and Key Vault identity client IDs or identity references.
`gateway` also supports `default_ssl_binding`. All four provider operation
timeouts can be configured under `timeouts`.

The focused plan-only contract preserves the legacy list-based `gateways`
input and checks all five endpoint types, repeated endpoints, local/remote
certificate and identity resolution, gateway-only SSL binding, and timeouts:

```bash
terraform -chdir=examples init -backend=false \
  -test-directory=tests/unit/apim/api_management_custom_domain
terraform -chdir=examples test \
  -test-directory=tests/unit/apim/api_management_custom_domain -no-color
```

The contract validates planned Terraform arguments only; it does not verify
Azure-side acceptance, Key Vault access, or deploy resources.
