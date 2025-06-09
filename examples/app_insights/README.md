# Azure App Insights

This module is part of the Cloud Adoption Framework landing zones for Azure on Terraform.

You can instantiate it directly using the following parameters:

```hcl
module "caf" {
  source  = "aztfmodnew/caf/azurerm"
  version = "~>4.30.0"
  app_insights = var.app_insights
  # You can add other objects as needed, e.g. resource_groups = var.resource_groups
}
```

The CAF Terraform module is iterative by default; you can instantiate as many objects as needed using the following structure:

```hcl
resource_to_be_created = {
  object1 = {
    # configuration details
  }
  object2 = {
    # configuration details
  }
}
```

You can review the complete set of examples in the [GitHub repository](https://github.com/aztfmod/terraform-azurerm-caf/tree/master/examples/app_insights).

---

## Inputs

| Nombre                | Tipo        | Descripción                                                                        | Obligatorio | Valor predeterminado |
| --------------------- | ----------- | ---------------------------------------------------------------------------------- | ----------- | -------------------- |
| `app_insights_name`   | string      | Nombre de la instancia de Application Insights.                                    | Sí          |                      |
| `location`            | string      | Ubicación donde se desplegará la instancia de Application Insights.                | Sí          |                      |
| `resource_group_name` | string      | Nombre del grupo de recursos donde se creará la instancia de Application Insights. | Sí          |                      |
| `tags`                | map(string) | Etiquetas para aplicar a la instancia de Application Insights.                     | No          | {}                   |

## Ejemplo de uso

```hcl
module "app_insights" {
  source              = "aztfmod/caf/azurerm//modules/app_insights"
  version             = "~>5.5.0"
  app_insights_name   = "mi-instancia-app-insights"
  location             = "East US"
  resource_group_name = "mi-grupo-recursos"
  tags                 = { environment = "producción" }
}
```
