#!/bin/bash

# Script de análisis previo para entender el estado actual de los módulos
# Identifica módulos con/sin azurecaf y recursos nombrados

set -e

REPO_ROOT="/home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf"
MODULES_DIR="$REPO_ROOT/modules"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Análisis de Módulos - Estado Actual del Naming${NC}"
echo "======================================================"

# Contadores
total_modules=0
with_azurecaf=0
without_azurecaf=0
no_named_resources=0
already_hybrid=0

echo ""
echo "Categoría | Módulo | Estado | Recurso Principal | Observaciones"
echo "----------|--------|--------|-------------------|---------------"

# Función para analizar módulo
analyze_module() {
    local module_path="$1"
    local module_name=$(basename "$module_path")
    local category_name=$(basename "$(dirname "$module_path")")
    
    total_modules=$((total_modules + 1))
    
    # Verificar recursos nombrados
    local has_named=0
    if grep -r "resource \"azurerm_" "$module_path" >/dev/null 2>&1; then
        has_named=$(grep -r "name\s*=" "$module_path"/*.tf 2>/dev/null | grep -v "resource_group_name\|location" | wc -l || echo "0")
    fi
    
    if [ "$has_named" -eq 0 ]; then
        echo "$category_name | $module_name | ⚪ Sin recursos nombrados | - | Saltará automáticamente"
        no_named_resources=$((no_named_resources + 1))
        return
    fi
    
    # Detectar recurso principal
    local main_resource="?"
    if [ -f "$module_path/$module_name.tf" ]; then
        main_resource=$(grep "resource \"azurerm_" "$module_path/$module_name.tf" 2>/dev/null | head -1 | sed 's/resource "//g' | sed 's/".*//g' || echo "?")
    fi
    if [ "$main_resource" = "?" ]; then
        main_resource=$(grep -r "resource \"azurerm_" "$module_path"/*.tf 2>/dev/null | head -1 | sed 's/.*resource "//g' | sed 's/".*//g' || echo "unknown")
    fi
    
    # Verificar estado actual
    if [ -f "$module_path/naming.tf" ] && grep -q "effective_naming" "$module_path/naming.tf" 2>/dev/null; then
        echo "$category_name | $module_name | ✅ Híbrido ya implementado | $main_resource | Listo"
        already_hybrid=$((already_hybrid + 1))
    elif [ -f "$module_path/azurecaf_name.tf" ] || grep -r "azurecaf_name" "$module_path"/*.tf 2>/dev/null | grep -q "resource"; then
        echo "$category_name | $module_name | 🔵 Con azurecaf existente | $main_resource | Actualizar a híbrido"
        with_azurecaf=$((with_azurecaf + 1))
    else
        echo "$category_name | $module_name | 🔴 Sin azurecaf | $main_resource | Implementar híbrido nuevo"
        without_azurecaf=$((without_azurecaf + 1))
    fi
}

# Recorrer todos los módulos
for category_dir in "$MODULES_DIR"/*; do
    if [ ! -d "$category_dir" ]; then
        continue
    fi
    
    # Verificar si es módulo directo o contiene submódulos
    if [ -f "$category_dir/main.tf" ] || [ -f "$category_dir/$(basename "$category_dir").tf" ]; then
        analyze_module "$category_dir"
    else
        for module_dir in "$category_dir"/*; do
            if [ -d "$module_dir" ]; then
                analyze_module "$module_dir"
            fi
        done
    fi
done

# Resumen
echo ""
echo -e "${BLUE}📊 Resumen del Análisis${NC}"
echo "========================"
echo "Total de módulos analizados: $total_modules"
echo ""
echo -e "${GREEN}✅ Ya implementado (híbrido): $already_hybrid${NC}"
echo -e "${BLUE}🔵 Con azurecaf (actualizar): $with_azurecaf${NC}"
echo -e "${RED}🔴 Sin azurecaf (implementar): $without_azurecaf${NC}"
echo -e "${YELLOW}⚪ Sin recursos nombrados: $no_named_resources${NC}"

echo ""
echo -e "${BLUE}🎯 Plan de Implementación${NC}"
echo "=========================="
echo "1. Módulos que se actualizarán: $((with_azurecaf + without_azurecaf))"
echo "2. Módulos que se saltarán: $((no_named_resources + already_hybrid))"
echo "3. Estimación de tiempo: ~$((with_azurecaf + without_azurecaf)) minutos"

echo ""
echo -e "${BLUE}🚀 Para ejecutar la implementación:${NC}"
echo "./scripts/implement-hybrid-naming.sh"

echo ""
echo -e "${YELLOW}⚠️  Recomendaciones:${NC}"
echo "- Hacer backup antes de ejecutar"
echo "- Probar en algunos módulos primero"
echo "- Revisar logs después de la ejecución"
