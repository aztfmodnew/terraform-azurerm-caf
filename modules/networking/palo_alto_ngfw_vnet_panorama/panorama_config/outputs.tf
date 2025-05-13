output "config" {
  description = "The structured Panorama configuration details."
  value       = local.panorama_details
  # The main NGFW resource expects these as direct string arguments within its 'panorama' block.
  # The provider handles any necessary encoding/encryption.
}
