# Application Gateway SSL profile

This multi-file example configures an Application Gateway platform with an
SSL profile, a self-signed Key Vault certificate, and a private DNS A record
for its private frontend IP. The profile and global SSL policy use the same
policy generation; Azure rejects a configuration that mixes legacy and
current SSL policy generations. It also exercises the legacy
`verify_client_cert_issuer_dn` input alias.

The variable files are supplied together:

- `configuration.tfvars`: global settings, resource group, and private DNS zone.
- `agw_platform.tfvars`: gateway configuration and SSL profile.
- `agw_application.tfvars`: backend application, listener, and routing.
- `certificates.tfvars`: self-signed Key Vault certificate.
- `keyvaults.tfvars`: Key Vault and access policies.
- `managed_identities.tfvars`: gateway identity.
- `network_security_group_definition.tfvars`: subnet NSG rules.
- `networking.tfvars`: VNet and public IP.

Run the repository mock plan from the repository root:

```bash
terraform -chdir=./examples test -test-directory=./tests/mock \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/configuration.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/agw_platform.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/agw_application.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/certificates.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/keyvaults.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/managed_identities.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/network_security_group_definition.tfvars \
  -var-file=../examples/networking/app_gateway/303-ssl-profile/networking.tfvars \
  -verbose
```
