#!/bin/bash

# Static Website NGFW DNAT Diagnostic Script
# Tests connectivity through Palo Alto Cloud NGFW with Private Endpoints

set -e

echo "🔍 Static Website NGFW DNAT Connectivity Diagnostic"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to extract values from Terraform outputs
extract_terraform_values() {
    echo -e "${BLUE}🔧 Extracting deployment values from Terraform...${NC}"
    
    if ! command -v terraform >/dev/null 2>&1; then
        echo -e "${RED}❌ Terraform not found in PATH${NC}"
        return 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}❌ jq not found in PATH (required for JSON parsing)${NC}"
        return 1
    fi
    
    # Extract values from terraform output
    local output_json
    output_json=$(terraform output -raw objects 2>/dev/null) || {
        echo -e "${RED}❌ Failed to get terraform outputs. Ensure you're in the correct directory with deployed state.${NC}"
        return 1
    }
    
    NGFW_PUBLIC_IP=$(echo "$output_json" | jq -r '.public_ip_addresses.ngfw_pip_dataplane1.ip_address // empty')
    STORAGE_ACCOUNT=$(echo "$output_json" | jq -r '.storage_accounts.static_website_storage.name // empty')
    STORAGE_WEB_URL=$(echo "$output_json" | jq -r '.storage_accounts.static_website_storage.primary_web_endpoint // empty')
    PE_IP=$(echo "$output_json" | jq -r '.private_endpoints.spoke_storage_vnet.subnet.snet_backend.storage_account.static_website_storage.pep.blob.private_service_connection[0].private_ip_address // empty')
    
    # Extract resource group names
    RESOURCE_GROUP_HUB=$(echo "$output_json" | jq -r '.resource_groups.ngfw_security_rg.name // empty')
    RESOURCE_GROUP_SPOKE=$(echo "$output_json" | jq -r '.resource_groups.staticweb_workload_rg.name // empty')
    
    # Validate extracted values
    if [[ -z "$NGFW_PUBLIC_IP" || -z "$STORAGE_ACCOUNT" || -z "$PE_IP" ]]; then
        echo -e "${RED}❌ Failed to extract required values from Terraform outputs${NC}"
        echo "  NGFW IP: ${NGFW_PUBLIC_IP:-'<missing>'}"
        echo "  Storage: ${STORAGE_ACCOUNT:-'<missing>'}"
        echo "  PE IP: ${PE_IP:-'<missing>'}"
        return 1
    fi
    
    # Extract web endpoint hostname
    WEB_HOST=$(echo "$STORAGE_WEB_URL" | sed 's|https://||' | sed 's|/||')
    
    echo -e "${GREEN}✅ Successfully extracted deployment values${NC}"
    return 0
}

# Try to extract dynamic values first, fallback to static values
if extract_terraform_values; then
    echo -e "${BLUE}📋 Dynamic Configuration (from Terraform):${NC}"
else
    echo -e "${YELLOW}⚠️  Using fallback static configuration${NC}"
    NGFW_PUBLIC_IP="132.196.140.192"
    STORAGE_ACCOUNT="bzptstststaticweb"
    RESOURCE_GROUP_HUB="bzpt-rg-hub-ngfw-security-rg"
    RESOURCE_GROUP_SPOKE="bzpt-rg-spoke-staticweb-workload-rg"
    PE_IP="10.200.1.4"
    WEB_HOST="$STORAGE_ACCOUNT.z20.web.core.windows.net"
    echo -e "${BLUE}📋 Static Configuration (fallback):${NC}"
fi

echo "  NGFW Public IP: $NGFW_PUBLIC_IP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  PE IP: $PE_IP"
echo "  Web Host: $WEB_HOST"
echo "  Hub RG: $RESOURCE_GROUP_HUB"
echo "  Spoke RG: $RESOURCE_GROUP_SPOKE"
echo ""

# Test 1: NGFW Public IP connectivity via HTTPS
echo -e "${BLUE}🔗 Test 1: NGFW Public IP HTTPS Connectivity${NC}"
if timeout 10 curl -k -s -o /dev/null -w "%{http_code}" https://$NGFW_PUBLIC_IP/ | grep -q "400"; then
    echo -e "${GREEN}✅ NGFW HTTPS port accessible (DNAT working)${NC}"
    DNAT_STATUS="✅ Working"
else
    echo -e "${RED}❌ NGFW HTTPS port not accessible${NC}"
    DNAT_STATUS="❌ Failed"
fi

# Test 2: NGFW Public IP connectivity with correct Host header
echo -e "${BLUE}🌐 Test 2: NGFW with Storage Account Host Header${NC}"
HTTP_CODE=$(timeout 10 curl -k -s -o /dev/null -w "%{http_code}" -H "Host: $STORAGE_ACCOUNT.blob.core.windows.net" https://$NGFW_PUBLIC_IP/ || echo "000")
if [[ "$HTTP_CODE" == "400" ]]; then
    echo -e "${GREEN}✅ Storage backend reachable via NGFW (HTTP $HTTP_CODE)${NC}"
    BACKEND_STATUS="✅ Working"
elif [[ "$HTTP_CODE" == "000" ]]; then
    echo -e "${RED}❌ Connection timeout to storage backend${NC}"
    BACKEND_STATUS="❌ Timeout"
else
    echo -e "${YELLOW}⚠️  Storage backend responding with HTTP $HTTP_CODE${NC}"
    BACKEND_STATUS="⚠️ HTTP $HTTP_CODE"
fi

# Test 2b: Static Website connectivity test
echo -e "${BLUE}📄 Test 2b: Static Website via NGFW${NC}"
if [[ -n "$WEB_HOST" ]]; then
    WEB_HTTP_CODE=$(timeout 10 curl -k -s -o /dev/null -w "%{http_code}" -H "Host: $WEB_HOST" https://$NGFW_PUBLIC_IP/ || echo "000")
    if [[ "$WEB_HTTP_CODE" == "200" ]]; then
        echo -e "${GREEN}✅ Static website accessible via NGFW (HTTP $WEB_HTTP_CODE)${NC}"
        WEB_STATUS="✅ Working"
    elif [[ "$WEB_HTTP_CODE" == "404" ]]; then
        echo -e "${YELLOW}⚠️  Static website endpoint reachable but content missing (HTTP $WEB_HTTP_CODE)${NC}"
        WEB_STATUS="⚠️ No Content"
    elif [[ "$WEB_HTTP_CODE" == "000" ]]; then
        echo -e "${RED}❌ Connection timeout to static website${NC}"
        WEB_STATUS="❌ Timeout"
    else
        echo -e "${YELLOW}⚠️  Static website responding with HTTP $WEB_HTTP_CODE${NC}"
        WEB_STATUS="⚠️ HTTP $WEB_HTTP_CODE"
    fi
else
    echo -e "${YELLOW}⚠️  Web host not available (using fallback config)${NC}"
    WEB_STATUS="⚠️ Unknown"
fi

# Test 3: Direct Private Endpoint connectivity (from within network)
echo -e "${BLUE}🔒 Test 3: Private Endpoint Direct Access${NC}"
# Try to find PE with dynamic naming first, fallback to static
PE_NAME_DYNAMIC="$(echo "$STORAGE_ACCOUNT" | tr '[:upper:]' '[:lower:]')-pe-blob"
PE_NAME_STATIC="bzpt-pe-static_website_storage-blob"

PE_STATUS="Not Found"
for PE_NAME in "$PE_NAME_DYNAMIC" "$PE_NAME_STATIC"; do
    PE_STATUS=$(az network private-endpoint show --name "$PE_NAME" --resource-group "$RESOURCE_GROUP_SPOKE" --query "provisioningState" -o tsv 2>/dev/null || echo "")
    if [[ -n "$PE_STATUS" && "$PE_STATUS" != "Not Found" ]]; then
        break
    fi
done

if [[ "$PE_STATUS" == "Succeeded" ]]; then
    echo -e "${GREEN}✅ Private Endpoint provisioned successfully${NC}"
    PE_HEALTH="✅ Healthy"
else
    echo -e "${RED}❌ Private Endpoint not found or failed: $PE_STATUS${NC}"
    PE_HEALTH="❌ $PE_STATUS"
fi

# Test 4: Storage Account public access status
echo -e "${BLUE}🛡️  Test 4: Storage Account Security Status${NC}"
PUBLIC_ACCESS=$(az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP_SPOKE" --query "publicNetworkAccess" -o tsv 2>/dev/null || echo "Unknown")
if [[ "$PUBLIC_ACCESS" == "Disabled" ]]; then
    echo -e "${GREEN}✅ Storage Account public access properly disabled${NC}"
    SECURITY_STATUS="✅ Secured"
else
    echo -e "${YELLOW}⚠️  Storage Account public access: $PUBLIC_ACCESS${NC}"
    SECURITY_STATUS="⚠️ $PUBLIC_ACCESS"
fi

# Test 5: Static Website configuration
echo -e "${BLUE}📄 Test 5: Static Website Configuration${NC}"
STATIC_WEB_STATUS=$(az storage blob service-properties show --account-name "$STORAGE_ACCOUNT" --auth-mode login --query "staticWebsite.enabled" -o tsv 2>/dev/null || echo "false")
if [[ "$STATIC_WEB_STATUS" == "true" ]]; then
    echo -e "${GREEN}✅ Static Website enabled${NC}"
    STATIC_STATUS="✅ Enabled"
    
    # Check for index.html
    INDEX_EXISTS=$(az storage blob exists --account-name "$STORAGE_ACCOUNT" --container-name '$web' --name 'index.html' --auth-mode login --query "exists" -o tsv 2>/dev/null || echo "false")
    if [[ "$INDEX_EXISTS" == "true" ]]; then
        echo -e "${GREEN}✅ index.html exists in \$web container${NC}"
        CONTENT_STATUS="✅ Ready"
    else
        echo -e "${RED}❌ index.html missing in \$web container${NC}"
        CONTENT_STATUS="❌ Missing"
    fi
else
    echo -e "${RED}❌ Static Website not enabled${NC}"
    STATIC_STATUS="❌ Disabled"
    CONTENT_STATUS="❌ N/A"
fi

# Test 6: DNS Resolution
echo -e "${BLUE}🌐 Test 6: DNS Resolution${NC}"
if nslookup "$STORAGE_ACCOUNT.blob.core.windows.net" >/dev/null 2>&1; then
    RESOLVED_IP=$(nslookup "$STORAGE_ACCOUNT.blob.core.windows.net" | grep "Address:" | tail -1 | awk '{print $2}')
    if [[ "$RESOLVED_IP" == "$PE_IP" ]]; then
        echo -e "${GREEN}✅ DNS resolves to Private Endpoint IP ($RESOLVED_IP)${NC}"
        DNS_STATUS="✅ PE Resolution"
    else
        echo -e "${YELLOW}⚠️  DNS resolves to public IP ($RESOLVED_IP)${NC}"
        DNS_STATUS="⚠️ Public IP"
    fi
else
    echo -e "${RED}❌ DNS resolution failed${NC}"
    DNS_STATUS="❌ Failed"
fi

# Test 7: NGFW Configuration Verification
echo -e "${BLUE}🔥 Test 7: NGFW DNAT Configuration${NC}"
# Try to get NGFW info using dynamic resource group
SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null || echo "")
if [[ -n "$SUBSCRIPTION_ID" && -n "$RESOURCE_GROUP_HUB" ]]; then
    DNAT_CONFIG=$(az rest --method GET --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_HUB/providers/PaloAltoNetworks.Cloudngfw/firewalls?api-version=2023-09-01" --query "value[0].properties" 2>/dev/null || echo "{}")
    if echo "$DNAT_CONFIG" | jq -e '.networkProfile' >/dev/null 2>&1; then
        echo -e "${GREEN}✅ NGFW configuration accessible${NC}"
        NGFW_CONFIG="✅ Configured"
    else
        echo -e "${RED}❌ NGFW configuration not accessible${NC}"
        NGFW_CONFIG="❌ Missing"
    fi
else
    echo -e "${YELLOW}⚠️  Cannot verify NGFW configuration (missing subscription/resource group info)${NC}"
    NGFW_CONFIG="⚠️ Unknown"
fi

# Test 8: Port connectivity test
echo -e "${BLUE}🔌 Test 8: Port Connectivity Scan${NC}"
if command -v nmap >/dev/null 2>&1; then
    NMAP_RESULT=$(nmap -p 443 --open "$NGFW_PUBLIC_IP" 2>/dev/null | grep "443/tcp" || echo "")
    if echo "$NMAP_RESULT" | grep -q "open"; then
        echo -e "${GREEN}✅ Port 443 is open and accessible${NC}"
        PORT_STATUS="✅ Open"
    else
        echo -e "${RED}❌ Port 443 is not accessible${NC}"
        PORT_STATUS="❌ Closed"
    fi
else
    # Fallback to netcat if nmap not available
    if timeout 5 bash -c "</dev/tcp/$NGFW_PUBLIC_IP/443" 2>/dev/null; then
        echo -e "${GREEN}✅ Port 443 is accessible (netcat test)${NC}"
        PORT_STATUS="✅ Open"
    else
        echo -e "${RED}❌ Port 443 is not accessible (netcat test)${NC}"
        PORT_STATUS="❌ Closed"
    fi
fi

# Summary Report
echo ""
echo -e "${BLUE}📊 DIAGNOSTIC SUMMARY${NC}"
echo "================================"
echo -e "DNAT Connectivity:     $DNAT_STATUS"
echo -e "Backend Reachability:  $BACKEND_STATUS"
echo -e "Static Website:        $WEB_STATUS"
echo -e "Private Endpoint:      $PE_HEALTH"
echo -e "Storage Security:      $SECURITY_STATUS"
echo -e "Static Web Config:     $STATIC_STATUS"
echo -e "Website Content:       $CONTENT_STATUS"
echo -e "DNS Resolution:        $DNS_STATUS"
echo -e "NGFW Configuration:    $NGFW_CONFIG"
echo -e "Port Connectivity:     $PORT_STATUS"

# Overall Status
FAILED_COUNT=$(echo -e "$DNAT_STATUS\n$BACKEND_STATUS\n$WEB_STATUS\n$PE_HEALTH\n$SECURITY_STATUS\n$STATIC_STATUS\n$CONTENT_STATUS\n$DNS_STATUS\n$NGFW_CONFIG\n$PORT_STATUS" | grep -c "❌" || echo "0")

echo ""
if [[ "$FAILED_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}🎉 ALL SYSTEMS OPERATIONAL - Static Website accessible via NGFW DNAT${NC}"
    echo ""
    echo -e "${GREEN}🌐 Access URLs:${NC}"
    echo -e "  Browser: https://$NGFW_PUBLIC_IP/ ${YELLOW}(expect SSL warnings)${NC}"
    echo -e "  Curl (blob): curl -k -H \"Host: $STORAGE_ACCOUNT.blob.core.windows.net\" https://$NGFW_PUBLIC_IP/"
    if [[ -n "$WEB_HOST" ]]; then
        echo -e "  Curl (web):  curl -k -H \"Host: $WEB_HOST\" https://$NGFW_PUBLIC_IP/"
    fi
    exit 0
elif [[ "$FAILED_COUNT" -le 2 ]]; then
    echo -e "${YELLOW}⚠️  MINOR ISSUES DETECTED - Basic functionality working${NC}"
    echo -e "${YELLOW}🌐 Access URL: https://$NGFW_PUBLIC_IP/ ${YELLOW}(may have issues)${NC}"
    exit 1
else
    echo -e "${RED}❌ MULTIPLE FAILURES DETECTED - System requires attention${NC}"
    echo ""
    echo -e "${RED}🔧 TROUBLESHOOTING SUGGESTIONS:${NC}"
    if echo "$DNAT_STATUS" | grep -q "❌"; then
        echo "  - Check NGFW security rules (destination should be 0.0.0.0/0)"
        echo "  - Verify DNAT rule configuration"
    fi
    if echo "$PORT_STATUS" | grep -q "❌"; then
        echo "  - Check firewall/NSG rules blocking port 443"
        echo "  - Verify NGFW public IP accessibility"
    fi
    if echo "$PE_HEALTH" | grep -q "❌"; then
        echo "  - Check Private Endpoint deployment and network configuration"
        echo "  - Verify VNet peering and routing"
    fi
    exit 2
fi