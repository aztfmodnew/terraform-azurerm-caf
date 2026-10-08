# IoT security solution

This example creates an IoT Hub, a security solution and a device security
group. It demonstrates the legacy `recommendations_enabled` settings mapped
to the current `recommendations` block. Current `recommendations` settings take
precedence when both forms are supplied.

The solution's `enabled` flag is independent of the list of
`disabled_data_sources`. This example keeps the solution enabled while
disabling TwinData and two recommendations.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/iot/111-iot-security-solution/configuration.tfvars \
  -verbose
```
