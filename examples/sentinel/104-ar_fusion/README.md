# Sentinel Fusion rule

The workspace sets `sentinel_onboarding = {}` to explicitly enable Microsoft
Sentinel before creating its Fusion rule. The SecurityInsights solution alone
does not create the onboarding state required by the service.

Onboarding is opt-in: existing Log Analytics configurations without this
setting are unchanged. The optional `customer_managed_key_enabled` setting
defaults to `false`; only enable it after preparing workspace encryption and
Key Vault permissions. Optional `timeouts` support `create`, `read` and
`delete`.

For an already-onboarded workspace, import its onboarding state before
enabling this setting:

```bash
terraform -chdir=./examples import \
  -var-file=./sentinel/104-ar_fusion/configuration.tfvars \
  'module.example.module.log_analytics["law1"].azurerm_sentinel_log_analytics_workspace_onboarding.sentinel["default"]' \
  '/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/WORKSPACE/providers/Microsoft.SecurityInsights/onboardingStates/defaults'
```

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/sentinel/104-ar_fusion/configuration.tfvars \
  -verbose
```
