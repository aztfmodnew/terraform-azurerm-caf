# Storage Account Static Website Module
#
# This module creates a static website configuration for an Azure Storage Account
# using the modern azurerm_storage_account_static_website resource.
#
# Features:
# - Configures static website hosting for a storage account
# - Sets index and error documents
# - Supports timeouts configuration
#
# Note: This module replaces the deprecated static_website block
# in azurerm_storage_account resource.