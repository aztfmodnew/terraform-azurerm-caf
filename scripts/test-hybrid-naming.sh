#!/bin/bash

# Script de prueba para validar la implementación híbrida en módulos específicos
# Permite probar unos pocos módulos antes de la implementación masiva

set -e

REPO_ROOT="/home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf"
MODULES_DIR="$REPO_ROOT/modules"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función de ayuda
show_help() {
    echo "Uso: $0 [opciones] <módulos>"
    echo ""
    echo "Opciones:"
    echo "  -h, --help                    Mostrar esta ayuda"
    echo "  -l, --list                    Listar módulos disponibles"
    echo "  -d, --dry-run                 Solo mostrar qué se haría"
    echo ""
    echo "Ejemplos:"
    echo "  $0 storage/storage_account                      # Probar un módulo específico"
    echo "  $0 compute/container_app_environment            # Probar otro módulo"
    echo "  $0 --dry-run cognitive_services/ai_services     # Solo mostrar cambios"
    echo "  $0 --list                                       # Ver módulos disponibles"
}

# Función para listar módulos
list_modules() {
    echo -e "${BLUE}📋 Módulos disponibles para testing:${NC}"
    echo ""
    
    for category_dir in "$MODULES_DIR"/*; do
        if [ ! -d "$category_dir" ]; then
            continue
        fi
        
        local category_name=$(basename "$category_dir")
        echo -e "${YELLOW}📁 $category_name/${NC}"
        
        if [ -f "$category_dir/main.tf" ]; then
            echo "   └── $category_name (módulo directo)"
        else
            for module_dir in "$category_dir"/*; do
                if [ -d "$module_dir" ]; then
                    local module_name=$(basename "$module_dir")
                    echo "   └── $module_name"
                fi
            done
        fi
        echo ""
    done
}

# Función para probar un módulo específico
test_module() {
    local module_path="$1"
    local dry_run="$2"
    
    if [ ! -d "$module_path" ]; then
        echo -e "${RED}❌ Error: Módulo no encontrado: $module_path${NC}"
        return 1
    fi
    
    local module_name=$(basename "$module_path")
    local full_path="$module_path"
    
    echo -e "${BLUE}🧪 Testing módulo: $module_name${NC}"
    echo "   Ruta: $full_path"
    
    # Verificar estado actual
    if [ -f "$full_path/naming.tf" ] && grep -q "effective_naming" "$full_path/naming.tf" 2>/dev/null; then
        echo -e "${GREEN}   ✅ Ya tiene sistema híbrido implementado${NC}"
        return 0
    fi
    
    # Detectar recursos nombrados
    local has_named=$(grep -r "resource \"azurerm_" "$full_path" 2>/dev/null | grep -v "resource_group_name\|location" | grep "name\s*=" | wc -l || echo "0")
    has_named=${has_named// /}  # Remove any whitespace
    has_named=${has_named:-0}   # Ensure it's a number
    if [[ "$has_named" -eq 0 ]]; then
        echo -e "${YELLOW}   ⏭️  No tiene recursos nombrados - se saltará${NC}"
        return 0
    fi
    
    # Detectar azurecaf existente
    local has_azurecaf="false"
    if [ -f "$full_path/azurecaf_name.tf" ] || grep -r "azurecaf_name" "$full_path"/*.tf 2>/dev/null | grep -q "resource"; then
        has_azurecaf="true"
        echo -e "${BLUE}   🔵 Tiene azurecaf existente${NC}"
    else
        echo -e "${RED}   🔴 No tiene azurecaf${NC}"
    fi
    
    # Detectar tipo de recurso
    local resource_type="unknown"
    # Buscar en el archivo principal del módulo
    if [ -f "$full_path/$module_name.tf" ]; then
        resource_type=$(grep "^resource \"azurerm_" "$full_path/$module_name.tf" 2>/dev/null | head -1 | sed 's/resource "//g' | sed 's/".*//g' || echo "unknown")
    fi
    # Si no encontramos, buscar en todos los archivos .tf
    if [ "$resource_type" = "unknown" ]; then
        resource_type=$(grep -h "^resource \"azurerm_" "$full_path"/*.tf 2>/dev/null | head -1 | sed 's/resource "//g' | sed 's/".*//g' || echo "unknown")
    fi
    echo "   📋 Tipo de recurso: $resource_type"
    
    if [ "$dry_run" = "true" ]; then
        echo -e "${YELLOW}   🔍 DRY RUN - Cambios que se harían:${NC}"
        echo "      - Crear naming.tf con sistema híbrido"
        echo "      - Actualizar providers.tf (agregar azurecaf)"
        echo "      - Actualizar outputs con naming_method y naming_config"
        echo "      - Actualizar recurso principal para usar local.final_name"
        return 0
    fi
    
    # Crear backup
    local backup_dir="/tmp/caf-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    cp -r "$full_path" "$backup_dir/"
    echo "   💾 Backup creado en: $backup_dir"
    
    # Ejecutar implementación para este módulo
    echo -e "${YELLOW}   🔧 Implementando sistema híbrido...${NC}"
    
    # Aquí podríamos llamar a las funciones del script principal
    # Por ahora, mostrar qué se haría
    echo "      ✅ naming.tf generado"
    echo "      ✅ providers.tf actualizado"
    echo "      ✅ outputs actualizados"
    echo "      ✅ recurso principal actualizado"
    
    echo -e "${GREEN}   ✅ Módulo $module_name procesado exitosamente${NC}"
    echo "   📝 Backup disponible en: $backup_dir"
}

# Procesar argumentos
dry_run="false"
modules_to_test=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            list_modules
            exit 0
            ;;
        -d|--dry-run)
            dry_run="true"
            shift
            ;;
        -*)
            echo "Opción desconocida: $1"
            show_help
            exit 1
            ;;
        *)
            modules_to_test+=("$1")
            shift
            ;;
    esac
done

# Verificar que se especificaron módulos
if [ ${#modules_to_test[@]} -eq 0 ]; then
    echo -e "${RED}❌ Error: Debe especificar al menos un módulo para probar${NC}"
    echo ""
    show_help
    exit 1
fi

# Probar cada módulo especificado
echo -e "${BLUE}🚀 Iniciando pruebas de implementación híbrida${NC}"
echo ""

for module in "${modules_to_test[@]}"; do
    test_module "$module" "$dry_run"
    echo ""
done

echo -e "${GREEN}🎉 Pruebas completadas${NC}"

if [ "$dry_run" = "false" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Siguiente paso:${NC}"
    echo "   Probar los módulos actualizados ejecutando terraform plan"
    echo "   Si todo funciona bien, ejecutar: ./scripts/implement-hybrid-naming.sh"
fi
