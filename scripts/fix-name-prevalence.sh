#!/bin/bash

# Script para asegurar que el output "name" del hybrid naming prevalezca
# Elimina otros outputs "name" y mantiene solo el del hybrid naming

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Archivo de log
LOG_FILE="fix-name-outputs.log"

# Función de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

echo -e "${BLUE}🔧 Asegurando que el output 'name' del hybrid naming prevalezca${NC}"
echo -e "${BLUE}=========================================================${NC}"

# Inicializar log
echo "=== Iniciando corrección de outputs name ===" > "$LOG_FILE"
log "Script iniciado"

# Verificar que estamos en el directorio correcto
if [ ! -d "modules" ]; then
    echo -e "${RED}❌ Error: No se encuentra directorio 'modules'. Ejecutar desde la raíz del proyecto.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Verificación inicial completada${NC}"

# Función para procesar archivos outputs.tf
fix_name_outputs() {
    local file="$1"
    local changes_made=false
    
    if [ -f "$file" ]; then
        # Verificar si tiene hybrid naming (local.final_name)
        if grep -q "local.final_name" "$file"; then
            echo -e "${YELLOW}  🔧 Procesando: $file (tiene hybrid naming)${NC}"
            
            # Hacer backup
            cp "$file" "$file.name-fix-backup"
            
            # Crear archivo temporal
            temp_file=$(mktemp)
            
            # Procesar el archivo línea por línea
            awk '
            BEGIN {
                in_hybrid_name_block = 0
                in_other_name_block = 0
                skip_block = 0
                hybrid_name_found = 0
            }
            
            # Detectar inicio de bloque output "name" con local.final_name (híbrido)
            /^output "name"/ {
                # Leer las siguientes líneas para ver si es el bloque híbrido
                current_pos = getline next_line
                if (current_pos > 0) {
                    full_block = $0 "\n" next_line
                    while ((getline next_line) > 0 && next_line !~ /^}/) {
                        full_block = full_block "\n" next_line
                    }
                    full_block = full_block "\n" next_line  # Incluir la llave de cierre
                    
                    if (full_block ~ /local\.final_name/) {
                        # Es el bloque híbrido, mantenerlo
                        print full_block
                        hybrid_name_found = 1
                    } else {
                        # Es otro bloque "name", comentarlo
                        print "# DEPRECATED - Replaced by hybrid naming output"
                        print "# " $0
                        split(full_block, lines, "\n")
                        for (i = 2; i <= length(lines); i++) {
                            if (lines[i] != "") print "# " lines[i]
                        }
                        print ""
                    }
                    next
                }
            }
            
            # Imprimir todas las demás líneas
            { print }
            ' "$file" > "$temp_file"
            
            # Verificar si se hicieron cambios
            if ! cmp -s "$file" "$temp_file"; then
                mv "$temp_file" "$file"
                changes_made=true
                log "✅ Corregido outputs en $file"
                echo -e "    ${GREEN}✅ Outputs corregidos${NC}"
            else
                rm "$temp_file"
                echo -e "    ${BLUE}ℹ️  No necesita corrección${NC}"
            fi
            
        else
            # No tiene hybrid naming, verificar si tiene output "name" normal
            if grep -q 'output "name"' "$file"; then
                echo -e "${BLUE}  ℹ️  $file tiene output 'name' pero no hybrid naming${NC}"
                log "ℹ️  $file tiene output name normal (sin hybrid)"
            fi
        fi
    fi
    
    echo "$changes_made"
}

# Procesar todos los archivos outputs.tf
echo -e "${YELLOW}📋 Procesando archivos outputs.tf...${NC}"

FIXED_COUNT=0
TOTAL_COUNT=0

find modules -name "outputs.tf" -type f | while read output_file; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    result=$(fix_name_outputs "$output_file")
    if [ "$result" = "true" ]; then
        FIXED_COUNT=$((FIXED_COUNT + 1))
    fi
done

# Verificar que no hay conflictos restantes
echo -e "\n${YELLOW}📋 Verificando que no hay conflictos...${NC}"

CONFLICTS=0
find modules -name "outputs.tf" -type f | while read output_file; do
    # Contar outputs "name" no comentados
    name_count=$(grep -c '^output "name"' "$output_file" 2>/dev/null || echo "0")
    
    if [ "$name_count" -gt 1 ]; then
        echo -e "${RED}  ⚠️  CONFLICTO: $output_file tiene $name_count outputs 'name'${NC}"
        log "⚠️  CONFLICTO en $output_file: $name_count outputs name"
        CONFLICTS=$((CONFLICTS + 1))
    fi
done

# Resumen final
echo -e "\n${BLUE}📊 RESUMEN DE CORRECCIONES${NC}"
echo -e "${BLUE}=========================${NC}"
echo -e "📁 Archivos procesados: ${BLUE}${TOTAL_COUNT}${NC}"
echo -e "✅ Archivos corregidos: ${GREEN}${FIXED_COUNT}${NC}"
echo -e "⚠️  Conflictos restantes: ${RED}${CONFLICTS}${NC}"

if [ "$CONFLICTS" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Corrección completada exitosamente${NC}"
    echo -e "${GREEN}Todos los outputs 'name' de hybrid naming ahora prevalecen${NC}"
else
    echo -e "\n${YELLOW}⚠️  Se encontraron conflictos que requieren revisión manual${NC}"
fi

log "Script completado. Archivos corregidos: $FIXED_COUNT, Conflictos: $CONFLICTS"
echo -e "\n${BLUE}Log guardado en: $LOG_FILE${NC}"

# Comandos de verificación
echo -e "\n${YELLOW}💡 Para verificar el resultado:${NC}"
echo -e "   # Ver outputs 'name' con hybrid naming:"
echo -e "   grep -r 'local.final_name' modules/*/outputs.tf"
echo -e ""
echo -e "   # Verificar que no hay duplicados:"
echo -e "   find modules -name 'outputs.tf' -exec sh -c 'count=\$(grep -c \"^output \\\"name\\\"\" \"\$1\" 2>/dev/null || echo 0); if [ \$count -gt 1 ]; then echo \"\$1: \$count outputs name\"; fi' _ {} \\;"
