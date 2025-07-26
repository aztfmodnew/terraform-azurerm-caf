resource "azurerm_resource_group_template_deployment" "ase" {

  name                = local.final_name
  resource_group_name = var.resource_group_name

  template_content = file(local.arm_filename)

  parameters_content = jsonencode(local.parameters_content)

  deployment_mode = "Incremental"

  timeouts {
    create = "10h"
    update = "10h"
    delete = "10h"
    read   = "5m"
  }
}

resource "null_resource" "destroy_ase" {

  triggers = {
    resource_id = lookup(azurerm_resource_group_template_deployment.ase.output_content, "id")
  }

  provisioner "local-exec" {
    command     = format("%s/scripts/destroy_resource.sh", path.module)
    when        = destroy
    interpreter = ["/bin/bash"]
    on_failure  = fail

    environment = {
      RESOURCE_IDS = self.triggers.resource_id
    }
  }

}

data "azurerm_app_service_environment_v3" "ase" {
  depends_on = [azurerm_resource_group_template_deployment.ase]

  name                = local.final_name
  resource_group_name = var.resource_group_name
}
