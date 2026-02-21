global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

management_locks = {
  lock1 = {
    name       = "example-lock"
    scope      = "/subscriptions/00000000-0000-0000-0000-000000000000"
    lock_level = "CanNotDelete"
    notes      = "This lock prevents accidental deletion of the subscription."
  }
}
