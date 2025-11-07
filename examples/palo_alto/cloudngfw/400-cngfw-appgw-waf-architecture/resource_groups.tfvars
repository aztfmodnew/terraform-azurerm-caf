# Examples: Cloud NGFW with Application Gateway and WAF
# Architecture based on Microsoft Best Practices:
# https://learn.microsoft.com/en-us/azure/partner-solutions/palo-alto/application-gateway
# 
# This example demonstrates the recommended architecture for deploying Cloud NGFW for Azure
# behind Azure Application Gateway with Web Application Firewall (WAF).
# 
# Architecture Overview:
# - Application Gateway with WAF provides Layer 7 protection and reverse proxy
# - Cloud NGFW provides network security with App-ID, threat prevention, and URL filtering
# - Traffic flow: Internet -> App Gateway (WAF) -> Cloud NGFW -> Backend workloads
# - User-defined routes force traffic through Cloud NGFW for inspection

resource_groups = {
  networking_rg = {
    name     = "cngfw-appgw-waf-example"
    location = "eastus"
    tags = {
      environment = "sandbox"
      deployment  = "cngfw-appgw-waf-architecture"
    }
  }
}
