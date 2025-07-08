storage_accounts = {
  static_website = {
    name                     = "ststaticwebsite"
    resource_group_key       = "static_website"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    
    # Enable static website hosting
    static_website = {
      index_document     = "index.html"
      error_404_document = "404.html"
    }

    # Configure blob properties with retention policies
    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      delete_retention_policy  = {
        days = 7
      }
      container_delete_retention_policy = {
        days = 7
      }
    }

    # Configure lifecycle management for cost optimization
    management_policy = [
      {
        name    = "static_website_lifecycle"
        enabled = true
        
        filter = {
          prefix_match = ["$web/"]
        }
        
        rule = {
          delete_after_days_since_modification_greater_than = 365
          
          # Move to cool tier after 30 days for infrequently accessed content
          tier_to_cool_after_days_since_modification_greater_than = 30
          
          # Move to archive tier after 90 days
          tier_to_archive_after_days_since_modification_greater_than = 90
        }
      }
    ]

    # Network access configuration
    network_rules = {
      default_action = "Allow"
      bypass         = ["AzureServices"]
    }

    tags = {
      purpose = "static website hosting"
      tier    = "standard"
    }
  }
}

# Storage containers to organize content
storage_containers = {
  web_content = {
    name                  = "$web"
    storage_account_key   = "static_website"
    container_access_type = "blob"
  }
}

# Upload sample files for the website
storage_account_blobs = {
  index_html = {
    name                   = "index.html"
    storage_account_key    = "static_website"
    storage_container_name = "$web"
    type                   = "Block"
    content_type          = "text/html"
    source_content        = <<-HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Static Website with Azure Front Door</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .container {
            max-width: 800px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        .subtitle {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        .feature {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .azure-logo {
            width: 100px;
            height: 100px;
            margin: 0 auto 1rem;
            background: #0078d4;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
        }
        .info {
            background: rgba(255, 255, 255, 0.05);
            padding: 1rem;
            border-radius: 10px;
            margin-top: 2rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="azure-logo">☁️</div>
        <h1>Welcome!</h1>
        <p class="subtitle">Static Website served by Azure Front Door</p>
        
        <div class="features">
            <div class="feature">
                <h3>🚀 High Performance</h3>
                <p>Microsoft's global CDN</p>
            </div>
            <div class="feature">
                <h3>🛡️ Security</h3>
                <p>WAF and DDoS protection</p>
            </div>
            <div class="feature">
                <h3>🌍 Global</h3>
                <p>Worldwide edge locations</p>
            </div>
            <div class="feature">
                <h3>📈 Scalable</h3>
                <p>Automatic auto-scaling</p>
            </div>
        </div>
        
        <div class="info">
            <p><strong>Technologies used:</strong></p>
            <p>Azure Storage Account (Static Website) + Azure Front Door + Terraform Azure CAF</p>
            <p><strong>Domain:</strong> <span id="domain"></span></p>
        </div>
    </div>
    
    <script>
        // Display current domain
        document.getElementById('domain').textContent = window.location.hostname;
        
        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            const features = document.querySelectorAll('.feature');
            features.forEach((feature, index) => {
                feature.style.animationDelay = `$${index * 0.1}s`;
                feature.style.animation = 'fadeInUp 0.6s ease forwards';
            });
        });
    </script>
    
    <style>
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</body>
</html>
HTML
  }
  
  error_404 = {
    name                   = "404.html"
    storage_account_key    = "static_website"
    storage_container_name = "$web"
    type                   = "Block"
    content_type          = "text/html"
    source_content        = <<-HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a52 100%);
            color: white;
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .container {
            max-width: 600px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        h1 {
            font-size: 6rem;
            margin: 0;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        h2 {
            font-size: 2rem;
            margin: 1rem 0;
        }
        p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .button {
            display: inline-block;
            padding: 12px 24px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 50px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
        }
        .button:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>404</h1>
        <h2>Page Not Found</h2>
        <p>Sorry, the page you are looking for does not exist or has been moved.</p>
        <a href="/" class="button">🏠 Back to Home</a>
    </div>
</body>
</html>
HTML
  }

  about_html = {
    name                   = "about.html"
    storage_account_key    = "static_website"
    storage_container_name = "$web"
    type                   = "Block"
    content_type          = "text/html"
    source_content        = <<-HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - Azure Front Door Demo</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
            text-align: center;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .container {
            max-width: 900px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        .architecture {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }
        .component {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .nav {
            margin-top: 2rem;
        }
        .nav a {
            display: inline-block;
            margin: 0 1rem;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.3s ease;
        }
        .nav a:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏗️ Solution Architecture</h1>
        
        <div class="architecture">
            <div class="component">
                <h3>👤 User</h3>
                <p>Accesses the website from anywhere in the world</p>
            </div>
            <div class="component">
                <h3>🌐 Azure Front Door</h3>
                <p>Global CDN that routes traffic to the nearest origin</p>
            </div>
            <div class="component">
                <h3>🗄️ Storage Account</h3>
                <p>Static website hosting with HTML, CSS and JS</p>
            </div>
            <div class="component">
                <h3>🛡️ WAF (Optional)</h3>
                <p>Web Application Firewall for security protection</p>
            </div>
            <div class="component">
                <h3>📊 Monitoring</h3>
                <p>Azure Monitor and Application Insights for telemetry</p>
            </div>
            <div class="component">
                <h3>🏷️ Custom Domain</h3>
                <p>Custom domain with automatic SSL certificate</p>
            </div>
        </div>
        
        <div style="text-align: left; background: rgba(255, 255, 255, 0.05); padding: 1.5rem; border-radius: 10px; margin: 2rem 0;">
            <h3>✨ Key features:</h3>
            <ul>
                <li><strong>Global CDN:</strong> Over 100 edge locations worldwide</li>
                <li><strong>Auto-scaling:</strong> Handles traffic spikes automatically</li>
                <li><strong>SSL/TLS:</strong> Free certificates and automatic renewal</li>
                <li><strong>Compression:</strong> Automatic content optimization</li>
                <li><strong>HTTP/2:</strong> Modern protocol for better performance</li>
                <li><strong>Analytics:</strong> Detailed performance and usage metrics</li>
                <li><strong>Health Monitoring:</strong> Automatic origin health verification</li>
                <li><strong>Load Balancing:</strong> Intelligent traffic distribution</li>
            </ul>
        </div>
        
        <div class="nav">
            <a href="/">🏠 Home</a>
            <a href="/about.html">ℹ️ About</a>
        </div>
    </div>
</body>
</html>
HTML
  }
}
