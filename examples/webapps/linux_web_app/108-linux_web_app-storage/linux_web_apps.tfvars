linux_web_apps = {
  webapp_storage = {
    resource_group_key = "webapp_storage"
    name               = "webapp_storage"
    service_plan_key   = "asp_storage"

    enabled = true

    site_config = {
      application_stack = {
        python_version = "3.8"
      }
    }

    storage_account = [
      {
        name        = "blobmount1"
        type        = "AzureBlob"
        account_key = "sa1"
        share_name  = "sc1"
        mount_path  = "/mnt/sc1"
      },
      {
        name        = "sharemount1"
        type        = "AzureFiles"
        account_key = "sa2"
        share_name  = "fs1"
        mount_path  = "/mnt/fs1"
      }
    ]
  }
}
