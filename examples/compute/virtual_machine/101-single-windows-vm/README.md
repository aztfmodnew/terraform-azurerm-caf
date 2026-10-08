# Windows VM with legacy automatic-update configuration

This example uses `enable_automatic_updates = true` and `AutomaticByOS` patching.
The module maps the old input to AzureRM's `automatic_updates_enabled` argument.
The current input name takes precedence when both forms are supplied.

The example includes networking, a public IP, diagnostic storage and a Key Vault
for the generated administrator credential. Credentials are sensitive Terraform
outputs; protect plan and state files.

```bash
terraform -chdir=./examples test -test-directory=./tests/mock \
  -var-file=../examples/compute/virtual_machine/101-single-windows-vm/configuration.tfvars \
  -verbose
```

Use unique naming prefixes and isolated state for live plan/apply/destroy.
