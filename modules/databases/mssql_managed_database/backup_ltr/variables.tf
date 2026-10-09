variable "database_id" {}
variable "settings" {
  description = "LTR settings: weeklyRetention, monthlyRetention, yearlyRetention, weekOfYear, optional backupStorageAccessTier, and optional create/read/update/delete timeouts."
  type        = any
}
