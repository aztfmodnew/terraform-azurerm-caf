#!/bin/bash

# Script para corregir errores críticos de la implementación híbrida
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a logs/quick-fix.log
}

# Crear directorio de logs si no existe
mkdir -p logs

echo -e "${BLUE}🔧 Reparación rápida de errores críticos...${NC}"
echo -e "${BLUE}📋 Log: logs/quick-fix.log${NC}"

log "🔧 Iniciando reparación rápida..."

# 1. Corregir outputs duplicados
echo -e "${YELLOW}📋 Paso 1: Corrigiendo outputs duplicados...${NC}"
log "🔧 Corrigiendo outputs duplicados..."

for module_dir in modules/*/*/*; do
    if [ -d "$module_dir" ]; then
        for output_file in "$module_dir"/{output.tf,outputs.tf}; do
            if [ -f "$output_file" ]; then
                # Contar outputs "name"
                name_count=$(grep -c '^output "name"' "$output_file" 2>/dev/null || echo "0")
                
                if [[ "$name_count" -gt 1 ]]; then
                    log "   🔧 Corrigiendo $output_file (duplicados: $name_count)"
                    
                    # Crear backup
                    cp "$output_file" "${output_file}.backup-$(date +%s)"
                    
                    # Usar awk para mantener solo el primer output "name"
                    awk '
                    BEGIN { in_name_block = 0; name_found = 0 }
                    /^output "name"/ { 
                        if (name_found) {
                            in_name_block = 1
                            next
                        } else {
                            name_found = 1
                            print
                            next
                        }
                    }
                    /^output / && in_name_block {
                        in_name_block = 0
                        print
                        next
                    }
                    /^}/ && in_name_block {
                        in_name_block = 0
                        next
                    }
                    !in_name_block { print }
                    ' "$output_file" > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"
                fi
            fi
        done
    fi
done

# 2. Corregir rutas del módulo local naming
echo -e "${YELLOW}📋 Paso 2: Corrigiendo rutas del módulo naming...${NC}"
log "🔧 Corrigiendo rutas del módulo naming..."

# Contar archivos con rutas incorrectas
total_files=$(find modules -name "naming.tf" -exec grep -l 'source = "../../naming"' {} \; | wc -l)
fixed_files=0

find modules -name "naming.tf" -exec grep -l 'source = "../../naming"' {} \; | while read file; do
    # Calcular la profundidad del módulo
    depth=$(echo "$file" | tr '/' '\n' | wc -l)
    depth=$((depth - 2))  # modules/category/module = 3 levels, so depth = 1
    
    # Construir la ruta relativa correcta
    relative_path=""
    for ((i=1; i<=depth; i++)); do
        relative_path="../$relative_path"
    done
    relative_path="${relative_path}naming"
    
    log "   🔧 Corrigiendo ruta en $file: ../../naming -> $relative_path"
    
    # Reemplazar la ruta
    sed -i.bak "s|source = \"../../naming\"|source = \"$relative_path\"|g" "$file"
    
    fixed_files=$((fixed_files + 1))
done

# 3. Verificar que el módulo naming existe
echo -e "${YELLOW}📋 Paso 3: Verificando módulo naming...${NC}"
if [ ! -d "modules/naming" ]; then
    log "❌ Módulo naming no encontrado en modules/"
    echo -e "${RED}❌ Error: Módulo naming no encontrado en modules/${NC}"
    exit 1
else
    log "✅ Módulo naming encontrado en modules/"
    echo -e "${GREEN}✅ Módulo naming encontrado en modules/${NC}"
fi

# 4. Verificar que examples/naming tiene configuraciones básicas
echo -e "${YELLOW}📋 Paso 4: Verificando ejemplos de naming...${NC}"
if [ ! -f "examples/naming/101-azurecaf-naming/configuration.tfvars" ]; then
    log "⚠️  Creando ejemplo básico de azurecaf..."
    mkdir -p examples/naming/101-azurecaf-naming
    cat > examples/naming/101-azurecaf-naming/configuration.tfvars << 'EOF'
# Basic example: azurecaf naming (default)
# Use the azurecaf provider for standard CAF naming

global_settings = {
  default_region = "region1"
  environment    = "demo"
  prefix         = "caf"
  
  regions = {
    region1 = "eastus"
    region2 = "westus"
  }
  
  # Use azurecaf (default behavior)
  naming = {
    use_azurecaf      = true
    use_local_module  = false
  }
}

resource_groups = {
  demo = {
    name = "demo-rg"
  }
}
EOF
fi

echo -e "${GREEN}✅ Reparación rápida completada${NC}"
log "✅ Reparación rápida completada"

echo -e "${BLUE}📋 Próximos pasos:${NC}"
echo -e "   1. Probar terraform init en examples/naming/101-azurecaf-naming"
echo -e "   2. Probar terraform plan para verificar funcionamiento"
echo -e "   3. Si hay errores, revisar logs en logs/quick-fix.log"

log "📋 Archivos corregidos: $fixed_files archivos naming.tf"
echo -e "${GREEN}🎉 Reparación completada. Ver logs en: logs/quick-fix.log${NC}"
