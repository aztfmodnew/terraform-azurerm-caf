#!/bin/bash
# Flexible Governance Demo Script

echo "🎯 Flexible Governance Naming System Demo"
echo "=========================================="
echo ""

echo "This demo shows how teams can customize naming while respecting organizational patterns."
echo ""

echo "📋 Configuration Overview:"
echo "- allow_resource_override = true  (teams can customize)"
echo "- resource_patterns defined for different Azure services"
echo "- Individual naming blocks allowed and respected"
echo ""

echo "🧪 Testing flexible governance..."
terraform plan -var-file="global_settings.tfvars" -var-file="resources.tfvars" -out="flexible.tfplan"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Plan successful! Here are the naming results:"
    echo ""
    
    echo "📊 Expected Naming Patterns:"
    echo "- global_pattern (Storage):     org-st-myapp-prod-westeurope-001"
    echo "- dev_override (Container App): team1_cae_devapp_dev_test"
    echo "- project_vault (Key Vault):   proj-secrets-shared-westeurope"
    echo "- pattern_based (Storage):     orglogsproduction001"
    echo ""
    
    echo "🎨 This demonstrates:"
    echo "✓ Global patterns as defaults"
    echo "✓ Team-specific overrides"
    echo "✓ Project-specific naming"
    echo "✓ Resource-type patterns"
    echo ""
    
    echo "To deploy: terraform apply flexible.tfplan"
    echo "To cleanup: terraform destroy -var-file=\"global_settings.tfvars\" -var-file=\"resources.tfvars\""
else
    echo "❌ Plan failed. Check configuration files."
fi
