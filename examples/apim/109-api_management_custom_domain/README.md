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
