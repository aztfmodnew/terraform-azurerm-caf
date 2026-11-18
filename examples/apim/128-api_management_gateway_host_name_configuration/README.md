# Simple gateway host name configuration

Creates a resource group, Developer APIM service, gateway registration, managed
identity, Key Vault, access policies, self-signed TLS certificate, APIM
certificate and gateway hostname configuration. Dependencies use local keys,
with no remote state or literal ARM IDs. Certificate material is generated in
Key Vault, not embedded in source. TLS 1.0 and 1.1 are explicitly disabled.

The detected deployment user/service principal receives Key Vault certificate
permissions; APIM's identity receives read permissions. The demonstration
certificate covers `api.example.com`. Replace the host, certificate subject and
SAN together for a real deployment; configure DNS and deploy the self-hosted
gateway runtime separately. Self-signed TLS requires client trust configuration.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/128-api_management_gateway_host_name_configuration/configuration.tfvars
```

Review before applying with the same file. Verify the configuration in APIM,
then validate DNS and an actual TLS handshake independently. For cleanup,
review and execute `destroy` with the same file after removing traffic/DNS
dependencies. Cleanup deletes all managed parents too; Key Vault soft-delete
retention applies. Developer APIM incurs charges while deployed.

See the [plan-only mock contract](../../../modules/apim/api_management_gateway_host_name_configuration/README.md);
mock plans do not prove DNS or TLS readiness.
