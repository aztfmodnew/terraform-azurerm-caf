# Event Grid delivery endpoints

This example creates a resource-group subscription delivering to a Storage
queue, another delivering to Event Hubs, and a storage system-topic subscription
delivering to the same Event Hub.

The system topic resolves its source storage account through a CAF key. Event
Hub destinations also use key-based references. The modules accept current
`eventhub_id`, `hybrid_connection_id`, `service_bus_queue_id` and
`service_bus_topic_id` settings while retaining the corresponding legacy
`*_endpoint_id` inputs.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/messaging/eventgrid/102-eventgrid_subscription/configuration.tfvars \
  -verbose
```

The example validates endpoint configuration; it does not consume delivered
events or exercise Service Bus and Relay destinations.
