To run this example you need create resources from the portal or reference existing ones.
Review the reference in the data_sources.tfvars

For `data_sources.vnets`, both modes are supported:
- explicit `id` (legacy behavior)
- `name` + `resource_group_name` (resolved through data sources)