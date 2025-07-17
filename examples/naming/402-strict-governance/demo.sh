#!/bin/bash
# Strict Governance Demo Script

echo "🔒 Strict Governance Naming System Demo"
echo "======================================="
echo ""

echo "This demo shows enforced organizational naming without individual overrides."
echo ""

echo "📋 Configuration Overview:"
echo "- allow_resource_override = false  (no individual overrides)"
echo "- resource_patterns enforced for all resources"
echo "- Individual naming blocks are IGNORED"
echo ""

echo "🧪 Testing strict governance..."
terraform plan -var-file="global_settings.tfvars" -var-file="resources.tfvars" -out="strict.tfplan"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Plan successful! Here are the naming results:"
    echo ""
    
    echo "📊 Expected Naming Patterns (ALL ENFORCED):"
    echo "- corporate_data (Storage):     corpstdataprod001"
    echo "- main_vault (Key Vault):       corp-kv-secrets-prod-westeurope"
    echo "- production_env (Container):   corp-cae-webapp-prod-001-001"
    echo "- ignored_override (Storage):   corpstlogsprod003 (override IGNORED)"
    echo ""
    
    echo "🛡️ This demonstrates:"
    echo "✓ Complete organizational control"
    echo "✓ Consistent naming across all resources"
    echo "✓ Individual overrides are ignored"
    echo "✓ Compliance-friendly governance"
    echo ""
    
    echo "To deploy: terraform apply strict.tfplan"
    echo "To cleanup: terraform destroy -var-file=\"global_settings.tfvars\" -var-file=\"resources.tfvars\""
else
    echo "❌ Plan failed. Check configuration files."
fi
