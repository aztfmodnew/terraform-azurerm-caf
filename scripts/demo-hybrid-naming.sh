#!/bin/bash
# =============================================================================
# Hybrid Naming System Demonstration Script
# =============================================================================
# This script demonstrates the three naming methods supported by the hybrid
# naming system: azurecaf, passthrough, and local module
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Hybrid Naming System Demonstration${NC}"
echo "=========================================="
echo ""

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLES_DIR="$BASE_DIR/examples"

# Function to demonstrate naming method
demonstrate_naming() {
    local naming_method="$1"
    local example_dir="$2"
    local description="$3"
    
    echo -e "${GREEN}📋 $naming_method${NC}"
    echo "   $description"
    echo ""
    
    if [ ! -d "$EXAMPLES_DIR/$example_dir" ]; then
        echo -e "${RED}   ❌ Directorio de ejemplo no encontrado: $example_dir${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}   📂 Ubicación: examples/$example_dir${NC}"
    echo -e "${YELLOW}   📄 Configuración:${NC}"
    
    # Show global settings
    if [ -f "$EXAMPLES_DIR/$example_dir/global_settings.tfvars" ]; then
        echo "      📋 Global Settings:"
        grep -E "(use_azurecaf|use_local_module|passthrough)" "$EXAMPLES_DIR/$example_dir/global_settings.tfvars" 2>/dev/null | sed 's/^/         /' || echo "         (usando configuración por defecto)"
        echo ""
    fi
    
    # Show resource configuration
    if [ -f "$EXAMPLES_DIR/$example_dir/ai_services.tfvars" ]; then
        echo "      🎯 Configuración del recurso:"
        head -10 "$EXAMPLES_DIR/$example_dir/ai_services.tfvars" | sed 's/^/         /'
        echo ""
    fi
    
    echo -e "${BLUE}   💡 Resultado esperado:${NC}"
    case "$naming_method" in
        "Método 1: azurecaf")
            echo "         Nombre: cog-example-dev-weu (CAF compliant con azurecaf provider)"
            echo "         Método: azurecaf"
            ;;
        "Método 2: Passthrough")
            echo "         Nombre: my-exact-ai-service-name (nombre exacto del usuario)"
            echo "         Método: passthrough"
            ;;
        "Método 3: Local Module")
            echo "         Nombre: myco-cog-chatbot-dev-weu-001-ai (CAF compliant con local module)"
            echo "         Método: local_module"
            ;;
    esac
    echo ""
    echo "---"
    echo ""
}

# Demonstrate all three methods
echo -e "${BLUE}Los siguientes ejemplos muestran las tres opciones de naming:${NC}"
echo ""

demonstrate_naming \
    "Método 1: azurecaf" \
    "naming/101-azurecaf-naming" \
    "Naming tradicional usando azurecaf provider (backward compatible)"

demonstrate_naming \
    "Método 2: Passthrough" \
    "naming/102-passthrough-naming" \
    "Nombres exactos sin transformación (útil para recursos con nombres específicos)"

demonstrate_naming \
    "Método 3: Local Module" \
    "naming/201-local-module-naming" \
    "Naming avanzado con control granular y governance (recomendado para nuevas implementaciones)"

echo -e "${GREEN}🎯 Ventajas del Sistema Híbrido${NC}"
echo "================================="
echo ""
echo "✅ Backward Compatibility: Todos los módulos existentes siguen funcionando"
echo "✅ Flexibilidad: Tres métodos para diferentes necesidades"
echo "✅ Governance: Control centralizado con override individual"
echo "✅ Migration Path: Transición gradual de azurecaf a local module"
echo "✅ Consistencia: Naming CAF compliant en todos los métodos"
echo ""

echo -e "${YELLOW}📖 Para más información:${NC}"
echo "- Documentación completa: examples/naming/README.md"
echo "- Scripts de implementación: scripts/"
echo "- Análisis del estado actual: ./scripts/analyze-naming-status.sh"
echo ""

echo -e "${GREEN}✨ ¡El sistema híbrido está listo para usar!${NC}"
