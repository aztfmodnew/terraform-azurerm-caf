# Azure Managed Grafana Module

This module deploys an Azure Managed Grafana instance following CAF and Well Architected Framework best practices.

### Example

```hcl
module "grafana" {
  source = "./modules/grafana"
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = true
  settings = {
    name = "caf-grafana"
    api_key_enabled = true
  }
  private_endpoints = {
    default = {
      name                = "grafana-pe"
      subnet_id           = module.subnet.id
      connection_name      = "grafana-conn"
      dns_zone_group_name  = "default"
      private_dns_zone_ids = [module.private_dns_zone.id]
    }
  }
}
```

## Usage Example

```hcl
module "grafana" {
  source = "./modules/grafana"
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location
  resource_group  = var.resource_group
  base_tags       = true
  settings = {
    name = "caf-grafana"
    api_key_enabled = true
  }
}
```
