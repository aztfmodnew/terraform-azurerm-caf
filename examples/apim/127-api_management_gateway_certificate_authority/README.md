# Simple gateway certificate authority

Creates a resource group, Developer APIM service, gateway registration, managed
identity, Key Vault, access policies, self-signed certificate, APIM certificate
and gateway trust association. All references use local keys. No remote state,
literal ARM IDs, PFX bytes, passwords or private keys are embedded.
Review the security impact of trusting a demo self-signed certificate.

The deploying identity needs Key Vault data-plane certificate permissions;
creation policies grant them to the detected signed-in user or service
principal. APIM's managed identity receives certificate/secret read permissions.
Certificate material is generated in Azure. This registers a self-hosted
gateway; deploying its runtime and testing trust are separate tasks.

After parent/root integration, from the repository root:

```shell
terraform -chdir=examples init -backend=false
terraform -chdir=examples plan -var-file=apim/127-api_management_gateway_certificate_authority/configuration.tfvars
```

Apply with the same file only after approval. Verify the gateway's certificate
authority trust setting in APIM and separately test backend TLS connectivity.
For cleanup, review `destroy` with the same file: removing trust can break
backend connections. Cleanup removes all managed parents too; Key Vault
soft-delete retention still applies. Developer APIM incurs charges while deployed.

See the [module mock contract](../../../modules/apim/api_management_gateway_certificate_authority/README.md);
plan-only mocks do not validate certificates or gateway TLS.
