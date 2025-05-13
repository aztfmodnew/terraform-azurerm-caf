locals {
  # No complex local transformations needed for this sub-module currently.
  # This file is here for structure and future-proofing.
  panorama_details = {
    panorama_server_1       = var.panorama_server_1
    panorama_server_2       = var.panorama_server_2
    virtual_machine_ssh_key = var.panorama_virtual_machine_ssh_key # Note: The main resource calls this virtual_machine_ssh_key
    device_group_name       = var.panorama_device_group_name
    template_name           = var.panorama_template_name
    host_name               = var.panorama_host_name
    # name field for panorama block is not explicitly in variables, can be added if needed or derived.
    # ssh_key for panorama server itself (distinct from vm ssh key) is also not in current vars.
  }
}
