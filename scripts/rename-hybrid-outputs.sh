#!/bin/bash

# Script para cambiar outputs "name" por "name_calculated" en hybrid naming
# Evita conflictos con outputs existentes

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Archivo de log
LOG_FILE="rename-outputs.log"

# Función de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

echo -e "${BLUE}🔧 Cambiando outputs 'name' por 'name_calculated' en Hybrid Naming${NC}"
echo -e "${BLUE}================================================================${NC}"

# Inicializar log
echo "=== Iniciando cambio de outputs name por name_calculated ===" > "$LOG_FILE"
log "Script iniciado"

# Verificar que estamos en el directorio correcto
if [ ! -d "modules" ]; then
    echo -e "${RED}❌ Error: No se encuentra directorio 'modules'. Ejecutar desde la raíz del proyecto.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Verificación inicial completada${NC}"

# Función para cambiar outputs en archivos
change_outputs() {
    local file="$1"
    local changed=false
    
    if [ -f "$file" ]; then
        # Verificar si tiene el output "name" de hybrid naming
        if grep -q '# Hybrid naming outputs' "$file" && grep -q 'output "name"' "$file"; then
            # Hacer backup
            cp "$file" "$file.rename-backup"
            
            # Crear archivo temporal
            temp_file=$(mktemp)
            
            # Cambiar solo los outputs "name" que están después de "# Hybrid naming outputs"
            awk '
            /# Hybrid naming outputs/ { 
                hybrid_section = 1 
                print
                next
            }
            /^# / && hybrid_section { 
                hybrid_section = 0 
            }
            /^output "[^"]*"/ && !hybrid_section { 
                hybrid_section = 0 
            }
            hybrid_section && /^output "name"/ { 
                gsub(/output "name"/, "output \"name_calculated\"")
                changed = 1
            }
            { print }
            END { if (changed) exit(1); else exit(0) }
            ' "$file" > "$temp_file"
            
            # Si AWK devuelve 1, significa que se hizo un cambio
            if [ $? -eq 1 ]; then
                mv "$temp_file" "$file"
                changed=true
                log "✅ Cambiado output en $file"
                echo "  ✅ $file"
            else
                rm "$temp_file"
            fi
        fi
    fi
    
    echo "$changed"
}

# Buscar todos los outputs.tf que tienen hybrid naming
echo -e "${YELLOW}📋 Cambiando outputs en módulos con hybrid naming...${NC}"

CHANGED_COUNT=0

# Buscar archivos outputs.tf
find modules -name "outputs.tf" -type f | while read output_file; do
    result=$(change_outputs "$output_file")
    if [ "$result" = "true" ]; then
        CHANGED_COUNT=$((CHANGED_COUNT + 1))
    fi
done

# También cambiar en naming.tf si tienen outputs
echo -e "${YELLOW}📋 Verificando archivos naming.tf...${NC}"

find modules -name "naming.tf" -type f | while read naming_file; do
    if [ -f "$naming_file" ]; then
        # Verificar si tiene output "name"
        if grep -q 'output "name"' "$naming_file"; then
            # Hacer backup
            cp "$naming_file" "$naming_file.rename-backup"
            
            # Cambiar el output
            sed -i 's/output "name"/output "name_calculated"/g' "$naming_file"
            
            log "✅ Cambiado output en $naming_file"
            echo "  ✅ $naming_file"
            CHANGED_COUNT=$((CHANGED_COUNT + 1))
        fi
    fi
done

# Resumen final
echo -e "\n${BLUE}📊 RESUMEN DE CAMBIOS${NC}"
echo -e "${BLUE}===================${NC}"
echo -e "✅ Archivos modificados: ${GREEN}${CHANGED_COUNT}${NC}"
echo -e "\n${GREEN}🎉 Cambio de outputs completado${NC}"
echo -e "${GREEN}Todos los outputs 'name' de hybrid naming son ahora 'name_calculated'${NC}"

log "Script completado. Archivos modificados: $CHANGED_COUNT"
echo -e "\n${BLUE}Log guardado en: $LOG_FILE${NC}"

# Sugerencia de verificación
echo -e "\n${YELLOW}💡 Para verificar los cambios:${NC}"
echo -e "   grep -r 'output \"name_calculated\"' modules/ | head -10"
echo -e "   grep -r '# Hybrid naming outputs' modules/ | head -5"
