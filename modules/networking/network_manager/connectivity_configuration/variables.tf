variable "global_settings" {
  description = "Global settings object"
  type        = any
}

variable "client_config" {
  description = "Client configuration object"
  type        = any
}

variable "remote_objects" {
  description = "Remote objects to be passed to the module."
  type        = any
}

variable "settings" {
  description = <<DESCRIPTION
Settings object for the module. This object should contain the following attributes:
- name: The name of the connectivity configuration.
- network_manager_id: The ID of the network manager.
- applies_to_groups: A list of objects that define the groups to which the configuration applies.
- connectivity_topology: The connectivity topology.
- delete_existing_peering_enabled: Whether to delete existing peerings.
- description: The description of the configuration.
- global_mesh_enabled: Whether the global mesh is enabled.
- use_hub_gateway: Whether to use the hub gateway.
- hub: The hub object.
- timeouts: The timeouts object.

The hub object should contain the following attributes:
- resource_id: The ID of the hub.
- resource_type: The type of the hub.

The timeouts object should contain the following attributes:
- create: The create timeout.
- read: The read timeout.
- update: The update timeout.
- delete: The delete timeout.

The applies_to_groups object should contain the following attributes:
- group_connectivity: The group connectivity.
- network_group_id: The ID of the network group.
- global_mesh_enabled: Whether the global mesh is enabled.
- use_hub_gateway: Whether to use the hub gateway.

```hcl
{
  name = string
  network_manager_id = string
  applies_to_groups = list(object({
    group_connectivity = string
    network_group_id = string
    global_mesh_enabled = bool
    use_hub_gateway = bool
  }))
  connectivity_topology = string
  delete_existing_peering_enabled = bool
  description = string
  global_mesh_enabled = bool
  hub = object({
    resource_id = string
    resource_type = string
  })
  timeouts = object({
    create = string
    read = string
    update = string
    delete = string
  })
}
```


Example:

```hcl
settings = {
  name = "connectivity-configuration"
  network_manager_id = "network-manager-id"
  applies_to_groups = [
    {
      group_connectivity = "group-connectivity"
      network_group_id = "network-group-id"
      global_mesh_enabled = true
      use_hub_gateway = true
    }
  ]
  connectivity_topology = "connectivity-topology"
  delete_existing_peering_enabled = true
  description = "description"
  global_mesh_enabled = true
  hub = {
    resource_id = "hub-resource-id"
    resource_type = "hub-resource-type"
  }
  timeouts = {
    create = "create-timeout"
    read = "read-timeout"
    update = "update-timeout"
    delete = "delete-timeout"
  }
}
```
DESCRIPTION
  type        = any
}
