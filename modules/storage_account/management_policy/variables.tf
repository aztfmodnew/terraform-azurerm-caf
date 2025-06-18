variable "settings" {
  description = <<DESCRIPTION
  The settings for the Azure Storage Management Policy. This object should define the rules, filters, and actions for the management policy.

  Parameters:
    rules: (Required) List of rule objects. Each rule supports:
      name: (Required) The name of the management policy rule. Must be unique within the storage account.
      enabled: (Required) Boolean to specify whether the rule is enabled.
      filters: (Required) Filters block object. Supports:
        prefix_match: (Optional) List of string prefixes to match.
        blob_types: (Required) List of blob types. Valid options: "blockBlob", "appendBlob".
        match_blob_index_tag: (Optional) List of objects for tag-based filtering. Each object supports:
          name: (Required) Tag name for filtering.
          operation: (Optional) Comparison operator. Default: "==".
          value: (Required) Tag value for filtering.
      actions: (Required) Actions block object. Supports:
        base_blob: (Optional) Object for base blob actions. Supports:
          tier_to_cool_after_days_since_modification_greater_than: (Optional) Number of days after last modification to tier to cool.
          tier_to_cool_after_days_since_last_access_time_greater_than: (Optional) Number of days after last access to tier to cool.
          tier_to_cool_after_days_since_creation_greater_than: (Optional) Number of days after creation to tier to cool.
          auto_tier_to_hot_from_cool_enabled: (Optional) Boolean to auto-tier to hot from cool.
          tier_to_archive_after_days_since_modification_greater_than: (Optional) Number of days after last modification to tier to archive.
          tier_to_archive_after_days_since_last_access_time_greater_than: (Optional) Number of days after last access to tier to archive.
          tier_to_archive_after_days_since_creation_greater_than: (Optional) Number of days after creation to tier to archive.
          tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) Number of days after last tier change to archive.
          tier_to_cold_after_days_since_modification_greater_than: (Optional) Number of days after last modification to tier to cold.
          tier_to_cold_after_days_since_last_access_time_greater_than: (Optional) Number of days after last access to tier to cold.
          tier_to_cold_after_days_since_creation_greater_than: (Optional) Number of days after creation to tier to cold.
          delete_after_days_since_modification_greater_than: (Optional) Number of days after last modification to delete.
          delete_after_days_since_last_access_time_greater_than: (Optional) Number of days after last access to delete.
          delete_after_days_since_creation_greater_than: (Optional) Number of days after creation to delete.
        snapshot: (Optional) Object for snapshot actions. Supports:
          change_tier_to_archive_after_days_since_creation: (Optional) Number of days after creation to archive.
          tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) Number of days after last tier change to archive.
          change_tier_to_cool_after_days_since_creation: (Optional) Number of days after creation to cool.
          tier_to_cold_after_days_since_creation_greater_than: (Optional) Number of days after creation to cold.
          delete_after_days_since_creation_greater_than: (Optional) Number of days after creation to delete.
        version: (Optional) Object for version actions. Supports:
          change_tier_to_archive_after_days_since_creation: (Optional) Number of days after creation to archive.
          tier_to_archive_after_days_since_last_tier_change_greater_than: (Optional) Number of days after last tier change to archive.
          change_tier_to_cool_after_days_since_creation: (Optional) Number of days after creation to cool.
          tier_to_cold_after_days_since_creation_greater_than: (Optional) Number of days after creation to cold.
          delete_after_days_since_creation: (Optional) Number of days after creation to delete.

  Example:
  {
    rules = [
      {
        name    = "rule1"
        enabled = true
        filters = {
          prefix_match = ["container1/prefix1"]
          blob_types   = ["blockBlob"]
          match_blob_index_tag = [
            {
              name      = "tag1"
              operation = "=="
              value     = "val1"
            }
          ]
        }
        actions = {
          base_blob = {
            tier_to_cool_after_days_since_modification_greater_than = 10
          }
        }
      }
    ]
  }
DESCRIPTION
  type        = any
}

variable "storage_account_id" {
  description = <<DESCRIPTION
  The ID of the Azure Storage Account to which the management policy will be applied.
  Example: "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Storage/storageAccounts/mystorageaccount"
DESCRIPTION
  type        = string
}
