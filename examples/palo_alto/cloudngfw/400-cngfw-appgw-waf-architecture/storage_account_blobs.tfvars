# Blobs for the Storage Account of the static website protected by WAF and NGFW

storage_account_blobs = {
  index_html = {
    name                   = "index.html"
    storage_account_key    = "demo_static_website"
    storage_container_name = "$web"
    type                   = "Block"
    content_type           = "text/html"
    source_content         = <<-HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Static Website with Azure WAF & NGFW</title>
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
        <p class="subtitle">Static Website protected by Azure WAF & Palo Alto NGFW</p>
        <div class="features">
            <div class="feature">
                <h3>🚀 High Performance</h3>
                <p>Microsoft's global CDN</p>
            </div>
            <div class="feature">
                <h3>🛡️ Security</h3>
                <p>WAF and NGFW protection</p>
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
            <p>Azure Storage Account (Static Website) + Application Gateway WAF + Palo Alto Cloud NGFW + Terraform Azure CAF</p>
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
                feature.style.animationDelay = "0s";
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
    storage_account_key    = "demo_static_website"
    storage_container_name = "$web"
    type                   = "Block"
    content_type           = "text/html"
    source_content         = <<-HTML
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
}
