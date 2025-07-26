#!/bin/bash

# Script simple para corregir problemas críticos del hybrid naming
# Evita usar grep -c para prevenir errores de sintaxis

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Archivo de log
LOG_FILE="simple-fix-hybrid.log"

# Función de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

echo -e "${BLUE}🔧 Script Simple para Corregir Hybrid Naming${NC}"
echo -e "${BLUE}=============================================${NC}"

# Inicializar log
echo "=== Iniciando corrección simple de hybrid naming ===" > "$LOG_FILE"
log "Script iniciado"

# 1. Verificar que estamos en el directorio correcto
if [ ! -d "modules" ]; then
    echo -e "${RED}❌ Error: No se encuentra directorio 'modules'. Ejecutar desde la raíz del proyecto.${NC}"
    exit 1
fi

# 2. Verificar que naming existe
if [ ! -d "modules/naming" ]; then
    echo -e "${RED}❌ Error: Módulo naming no encontrado en modules/naming${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Verificaciones iniciales completadas${NC}"

# 3. Corregir rutas de módulo naming
echo -e "${YELLOW}📋 Corrigiendo rutas del módulo naming...${NC}"

FIXED_PATHS=0

# Buscar todos los naming.tf
find modules -name "naming.tf" -type f | while read naming_file; do
    if [ -f "$naming_file" ]; then
        # Verificar si contiene la ruta incorrecta (sin usar grep -c)
        if grep -q 'source = "../../naming"' "$naming_file"; then
            # Calcular la profundidad del módulo
            module_dir=$(dirname "$naming_file")
            
            # Contar niveles desde modules/
            # Por ejemplo: modules/category/module -> depth = 2
            depth=$(echo "$module_dir" | sed 's|modules/||' | tr '/' '\n' | wc -l)
            
            # Construir ruta relativa
            relative_path=""
            for ((i=1; i<=depth; i++)); do
                relative_path="../$relative_path"
            done
            relative_path="${relative_path}naming"
            
            # Hacer backup
            cp "$naming_file" "$naming_file.simple-backup"
            
            # Reemplazar la ruta
            sed -i "s|source = \"../../naming\"|source = \"$relative_path\"|g" "$naming_file"
            
            echo "  ✅ Corregido: $naming_file -> $relative_path"
            log "Corregida ruta en $naming_file: $relative_path"
            FIXED_PATHS=$((FIXED_PATHS + 1))
        fi
    fi
done

echo -e "${GREEN}✅ Rutas de naming corregidas${NC}"

# 4. Eliminar outputs duplicados "name"
echo -e "${YELLOW}📋 Eliminando outputs duplicados 'name'...${NC}"

FIXED_OUTPUTS=0

# Buscar archivos outputs.tf que tienen outputs duplicados
find modules -name "outputs.tf" -type f | while read output_file; do
    if [ -f "$output_file" ]; then
        # Contar ocurrencias de 'output "name"' (sin grep -c para evitar errores)
        name_count=$(grep 'output "name"' "$output_file" | wc -l)
        
        if [ "$name_count" -gt 1 ]; then
            echo "  🔧 Corrigiendo duplicados en: $output_file"
            
            # Hacer backup
            cp "$output_file" "$output_file.simple-backup"
            
            # Crear archivo temporal sin duplicados
            temp_file=$(mktemp)
            
            # Eliminar duplicados manteniendo solo el primer output "name"
            awk '
            /^output "name"/ {
                if (!seen_name) {
                    seen_name = 1
                    name_block = 1
                    print
                    next
                } else {
                    name_block = 1
                    next
                }
            }
            name_block && /^}/ {
                if (seen_name == 1) {
                    seen_name = 2
                    print
                    name_block = 0
                    next
                } else {
                    name_block = 0
                    next
                }
            }
            !name_block { print }
            ' "$output_file" > "$temp_file"
            
            # Reemplazar archivo original
            mv "$temp_file" "$output_file"
            
            echo "    ✅ Eliminados duplicados en $output_file"
            log "Eliminados outputs duplicados en $output_file"
            FIXED_OUTPUTS=$((FIXED_OUTPUTS + 1))
        fi
    fi
done

echo -e "${GREEN}✅ Outputs duplicados eliminados${NC}"

# 5. Verificar que no hay errores básicos de sintaxis
echo -e "${YELLOW}📋 Verificando sintaxis básica...${NC}"

# Buscar archivos con posibles problemas
SYNTAX_ISSUES=0

find modules -name "*.tf" -type f | while read tf_file; do
    # Verificar balanceado de llaves
    open_braces=$(grep -o '{' "$tf_file" | wc -l)
    close_braces=$(grep -o '}' "$tf_file" | wc -l)
    
    if [ "$open_braces" -ne "$close_braces" ]; then
        echo "  ⚠️  Posible problema de llaves en: $tf_file (abrir: $open_braces, cerrar: $close_braces)"
        log "Posible problema de sintaxis en $tf_file"
        SYNTAX_ISSUES=$((SYNTAX_ISSUES + 1))
    fi
done

# 6. Resumen final
echo -e "\n${BLUE}📊 RESUMEN DE CORRECCIONES${NC}"
echo -e "${BLUE}=========================${NC}"
echo -e "✅ Rutas de naming corregidas: ${GREEN}${FIXED_PATHS}${NC}"
echo -e "✅ Outputs duplicados eliminados: ${GREEN}${FIXED_OUTPUTS}${NC}"
echo -e "⚠️  Posibles problemas de sintaxis: ${YELLOW}${SYNTAX_ISSUES}${NC}"

if [ "$SYNTAX_ISSUES" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Correcciones completadas sin problemas críticos${NC}"
    echo -e "${GREEN}Ahora puedes probar terraform init y plan en examples/naming/201-local-module-naming${NC}"
else
    echo -e "\n${YELLOW}⚠️  Se encontraron posibles problemas de sintaxis. Revisar archivos marcados.${NC}"
fi

log "Script completado"
echo -e "\n${BLUE}Log guardado en: $LOG_FILE${NC}"
