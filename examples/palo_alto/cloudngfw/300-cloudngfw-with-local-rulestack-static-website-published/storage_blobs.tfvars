# Static Website Content Configuration
# This file contains the static website content that will be uploaded to the storage account
# The content will be uploaded to the spoke network storage account for the static website

storage = {
  storage_account_blobs = {
    static_website_content = {

      # Main index page showcasing the hub and spoke architecture
      index_html = {
        name                   = "index.html"
        storage_account_key    = "static_website_storage"
        storage_container_name = "$web"
        type                   = "Block"
        content_type           = "text/html"

        source = {
          filename = "./website_content/index.html"
        }
      }

      # 404 error page with security messaging
      error_404_html = {
        name                   = "404.html"
        storage_account_key    = "static_website_storage"
        storage_container_name = "$web"
        type                   = "Block"
        content_type           = "text/html"

        source = {
          filename = "./website_content/404.html"
        }
      }

      # CSS stylesheet for responsive design
      styles_css = {
        name                   = "styles.css"
        storage_account_key    = "static_website_storage"
        storage_container_name = "$web"
        type                   = "Block"
        content_type           = "text/css"

        source = {
          filename = "./website_content/styles.css"
        }
      }

      # Robots.txt for SEO and web crawlers
      robots_txt = {
        name                   = "robots.txt"
        storage_account_key    = "static_website_storage"
        storage_container_name = "$web"
        type                   = "Block"
        content_type           = "text/plain"

        source = {
          filename = "./website_content/robots.txt"
        }
      }
    }
  }
}
