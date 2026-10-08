# AzureRM 5.8 compatibility tests

These tests use mocked providers and require no Azure subscription. They assert
legacy input mappings and current-name precedence rather than only checking
configuration syntax.

From the repository root:

```bash
terraform -chdir=examples init -backend=false -test-directory=tests/azurerm_5_8
terraform -chdir=examples test -test-directory=tests/azurerm_5_8 -no-color
```

Use AzureRM 5.8.0 to reproduce the migration validation. The provider constraint
allows later 5.8 patch versions; check the selected version in the lock file.

Coverage includes Front Door actions, condition negation and caching; Cosmos DB
authentication inversion; load-balancer flag aliases; the legacy pipeline
metrics typo; Kusto language-extension shapes; IoT recommendations; Key Vault
contact creation and explicit null handling; APIM certificate references; and
Container App template grace periods and explicit rejection of legacy per-probe
grace periods. ASE output JSON decoding, ASE/ASEv3 private DNS zone-ID
resolution, and the Service Plan ASEv3 reference are also covered. The removed
Linux Web App Ruby runtime is checked for an explicit migration error.

Full-framework example mock plans remain in `../mock`. Supply every variable
file for multi-file examples, including AI Services and Application Gateway.
Mock success does not verify Azure API behavior or migrate existing state.
`recovery_vault.tftest.hcl` verifies that omitted/true legacy soft-delete settings
are accepted and explicit false is rejected instead of silently ignored.
See [migration requirements](../../../CHANGELOG.md) before upgrading a deployed
landing zone.

`storage_cmk.tftest.hcl` exercises the root CMK aggregator with direct URI precedence,
omitted/null/empty versions, explicit versions, key-name precedence, older remote
key outputs, ARM-only cross-subscription vault references and null CMK settings.
The ARM lookup is mocked, including a sovereign-cloud vault endpoint.
