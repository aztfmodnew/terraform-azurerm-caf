output "storage_account" {
  value       = module.storage_account
  description = "Map of local landing zone storage account private endpoint modules keyed by storage account key. Each entry exposes pep map keyed by subresource (e.g., blob)."
}

output "storage_account_remote" {
  value       = module.storage_account_remote
  description = "Map of remote landing zone storage account private endpoint modules keyed by storage account key. Each entry exposes pep map keyed by subresource (e.g., blob)."
}