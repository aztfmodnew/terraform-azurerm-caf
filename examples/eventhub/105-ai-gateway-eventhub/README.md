# AI Gateway Event Hub

Creates an Event Hub Namespace with local authentication disabled, public
network access disabled, TLS 1.2, a user-assigned identity, two hubs, and a
consumer group. No SAS authorization rule is created.

The example also demonstrates the supported CAF role mapping at namespace
scope, granting `Azure Event Hubs Data Sender` to the managed identity. Hub-level
role scopes are not included because that scope is not wired into the root role
assignment object inventory.

Run the shared mock plan from `examples/`:

```shell
terraform test \
  -test-directory=./tests/mock \
  -var-file=./eventhub/105-ai-gateway-eventhub/configuration.tfvars \
  -verbose
```

This validates Terraform configuration and dependency wiring only. It does not
verify Azure service-side RBAC propagation or deploy any resource.
