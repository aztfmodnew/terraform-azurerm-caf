locals {
  arm_filename = "${path.module}/arm_ase_isolated.json"

  # this is the format required by ARM templates
  parameters_content = {
    aseName = {
      value = azurecaf_name.ase.result
    }
    aseResourceGroupName = {
      value = var.resource_group_name
    }
    location = {
      value = var.location
    }
    kind = {
      value = var.kind
    }
    zone = {
      value = var.zone
    }
    subnet_id = {
      value = var.subnet_id
    }
    subnet_name = {
      value = var.subnet_name
    }
    internalLoadBalancingMode = {
      value = var.internalLoadBalancingMode
    }
    frontEndSize = {
      value = var.front_end_size
    }
    frontEndCount = {
      value = var.front_end_count
    }
    resourceTags = {
      value = local.tags
    }
  }
}