# Private API Management

This 200-level scenario deploys an API Management service with a private
endpoint for its `Gateway` subresource. It keeps APIM out of VNet injection
mode and creates the
`privatelink.azure-api.net` private DNS zone linked to the private-endpoint
subnet's VNet.

The Standard tier is used because inbound Private Link is unsupported on the
Consumption tier. The example has no AI Services or Azure Monitor Private Link
Scope dependency.

The private endpoint supports direct `subnet_id` references or CAF
`vnet_key`/`subnet_key` references. Private DNS zone IDs can be supplied
directly in `private_dns.ids`, or resolved from combined objects with
`private_dns.keys`.

## Deployment sequence

Keep `public_network_access_enabled = true` for the first apply so APIM and
its private endpoint can be created. After the endpoint is provisioned, set
`public_network_access_enabled = false` and apply again to disable public
access. Disabling public access in the initial apply is unsafe because APIM
cannot create the dependent private endpoint in that state.
