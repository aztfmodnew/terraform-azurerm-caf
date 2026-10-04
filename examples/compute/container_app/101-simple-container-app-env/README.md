# Container App with startup and liveness probes

This example creates a Container Apps environment and an Nginx app with HTTP
startup and liveness probes. AzureRM 5.8 configures termination grace at
`template.termination_grace_period_seconds`, demonstrated with 45 seconds.

The former per-probe `termination_grace_period_seconds` settings are no longer
supported. CAF rejects them explicitly rather than silently dropping them.
Move the intended app-wide grace period to the template.

The environment explicitly defaults `logs_destination` to `log-analytics`,
preserving existing workspace-based logging under AzureRM 5.8. Selecting
`azure-monitor` omits the workspace ID because the provider prohibits that
combination. An explicit null destination selects streaming-only logs.

The custom-domain verification ID and the root aggregate output are sensitive,
matching the provider's sensitivity declaration.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/compute/container_app/101-simple-container-app-env/configuration.tfvars \
  -verbose
```
