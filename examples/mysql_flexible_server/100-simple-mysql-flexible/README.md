# MySQL Flexible Server

This example creates a MySQL Flexible Server, a database, server configuration,
firewall rules and a Key Vault for generated administrator credentials.

The example input remains `mysql_flexible_server`. The examples wrapper passes
it to the root module as `database.mysql_flexible_servers`; the plural root
collection name is required for the server to be instantiated.

The module output `mysql_flexible_server_public_network_access_enabled` remains
a boolean. Under AzureRM 5.8 it is derived from whether the server's
`public_network_access` value is `Enabled`.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/mysql_flexible_server/100-simple-mysql-flexible/configuration.tfvars \
  -verbose
```

The firewall addresses are illustrative; this example does not test database
client connectivity.
