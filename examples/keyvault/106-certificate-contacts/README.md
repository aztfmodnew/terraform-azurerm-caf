# Key Vault certificate contacts

AzureRM 5.8 manages certificate contacts through the standalone
`azurerm_key_vault_certificate_contacts` resource. CAF preserves the existing
`keyvaults.<key>.contacts` map, including optional contact names and phone
numbers, and waits for the initial access policies before creating contacts.

The deployment principal requires `ManageContacts` certificate permission and
network access to the vault. This example supplies an access policy for the
logged-in principal. No certificates are issued and no contact notifications
are triggered by the example.

For an existing deployment previously using inline contacts, back up the state
and import the existing contact collection before applying. There is no resource
address for an inline block that a `moved` block could relocate:

```bash
terraform -chdir=examples import \
  'module.example.module.keyvaults["contacts"].azurerm_key_vault_certificate_contacts.contacts["contacts"]' \
  https://<existing-vault-name>.vault.azure.net/certificates/contacts
```

Pass the same var-files and backend/workspace used by the existing deployment.
Do not remove the vault itself from state.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/keyvault/106-certificate-contacts/configuration.tfvars \
  -verbose
```
