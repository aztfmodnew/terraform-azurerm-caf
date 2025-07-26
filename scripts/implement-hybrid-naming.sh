#!/bin/bash

# Script para implementar el sistema híbrido de naming en todos los módulos
# Maneja tanto módulos con azurecaf existente como módulos sin azurecaf

set -e

# Configuración
REPO_ROOT="/home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf"
MODULES_DIR="$REPO_ROOT/modules"
PROGRESS_DIR="$REPO_ROOT/examples/.tmp-hybrid-naming-progress"
LOG_FILE="$PROGRESS_DIR/deployment.log"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función de logging
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Función para detectar si un módulo tiene recursos nombrados
has_named_resources() {
    local module_path="$1"
    
    # Buscar recursos de Azure con atributo 'name'
    if grep -r "resource \"azurerm_" "$module_path" | grep -q "\.tf:" 2>/dev/null; then
        # Verificar si algún recurso tiene atributo name
        if grep -r "name\s*=" "$module_path"/*.tf 2>/dev/null | grep -v "resource_group_name\|location" | grep -q "name"; then
            return 0
        fi
    fi
    return 1
}

# Función para detectar si ya tiene azurecaf_name
has_azurecaf_naming() {
    local module_path="$1"
    
    if [ -f "$module_path/azurecaf_name.tf" ]; then
        return 0
    fi
    
    if grep -r "azurecaf_name" "$module_path"/*.tf 2>/dev/null | grep -q "resource"; then
        return 0
    fi
    
    return 1
}

# Función para detectar el tipo de recurso principal
detect_resource_type() {
    local module_path="$1"
    
    # Buscar el archivo principal del módulo (generalmente nombrado igual que el directorio)
    local module_name=$(basename "$module_path")
    
    if [ -f "$module_path/$module_name.tf" ]; then
        local resource_line=$(grep "resource \"azurerm_" "$module_path/$module_name.tf" | head -1)
        if [ -n "$resource_line" ]; then
            echo "$resource_line" | sed 's/resource "//g' | sed 's/".*//g'
            return 0
        fi
    fi
    
    # Buscar en todos los archivos .tf
    local resource_line=$(grep -r "resource \"azurerm_" "$module_path"/*.tf 2>/dev/null | head -1)
    if [ -n "$resource_line" ]; then
        echo "$resource_line" | sed 's/.*resource "//g' | sed 's/".*//g'
        return 0
    fi
    
    echo "azurerm_unknown"
}

# Función para generar naming.tf híbrido
generate_hybrid_naming() {
    local module_path="$1"
    local resource_type="$2"
    local has_azurecaf="$3"
    
    local naming_file="$module_path/naming.tf"
    
    cat > "$naming_file" << EOF
# Hybrid naming system for $resource_type
# Supports three naming methods: passthrough, azurecaf, and local module
# With individual resource override capability and governance controls

locals {
  # Determine naming method based on global settings priority:
  # 1. Passthrough (exact names)
  # 2. Local module (configurable CAF naming)
  # 3. Azurecaf (provider-based CAF naming)
  # 4. Fallback (original name)
  use_passthrough   = var.global_settings.passthrough
  use_local_module  = !local.use_passthrough && try(var.global_settings.naming.use_local_module, false)
  use_azurecaf      = !local.use_passthrough && !local.use_local_module && try(var.global_settings.naming.use_azurecaf, true)

  # Base name from settings
  base_name = var.settings.name
  
  # Resource type for pattern lookup
  resource_type = "$resource_type"
  
  # Control de governance - permite override individual
  allow_individual_override = try(var.global_settings.naming.allow_resource_override, true)
  
  # Hybrid naming configuration with fallback hierarchy:
  # settings.naming → global resource patterns → global defaults
  effective_naming = local.allow_individual_override ? {
    environment     = try(var.settings.naming.environment, var.global_settings.environment)
    region          = try(var.settings.naming.region, try(var.global_settings.regions[var.global_settings.default_region], ""))
    instance        = try(var.settings.naming.instance, try(var.settings.instance, ""))
    prefix          = try(var.settings.naming.prefix, var.global_settings.prefix)
    suffix          = try(var.settings.naming.suffix, var.global_settings.suffix)
    separator       = try(var.settings.naming.separator,
                         try(var.global_settings.naming.resource_patterns[local.resource_type].separator, var.global_settings.separator))
    component_order = try(var.settings.naming.component_order,
                         try(var.global_settings.naming.resource_patterns[local.resource_type].component_order, var.global_settings.naming.component_order))
    clean_input     = try(var.settings.naming.clean_input, var.global_settings.clean_input)
    validate        = try(var.settings.naming.validate, var.global_settings.naming.validate)
  } : {
    # Modo controlado - solo patrones globales (no override individual)
    environment     = var.global_settings.environment
    region          = try(var.global_settings.regions[var.global_settings.default_region], "")
    instance        = try(var.settings.instance, "")
    prefix          = var.global_settings.prefix
    suffix          = var.global_settings.suffix
    separator       = try(var.global_settings.naming.resource_patterns[local.resource_type].separator, var.global_settings.separator)
    component_order = try(var.global_settings.naming.resource_patterns[local.resource_type].component_order, var.global_settings.naming.component_order)
    clean_input     = var.global_settings.clean_input
    validate        = var.global_settings.naming.validate
  }
}

# Local naming module (conditional)
module "local_naming" {
  source = "../../naming"
  count  = local.use_local_module ? 1 : 0

  resource_type   = local.resource_type
  name            = local.base_name
  environment     = local.effective_naming.environment
  region          = local.effective_naming.region
  instance        = local.effective_naming.instance
  prefix          = local.effective_naming.prefix
  suffix          = local.effective_naming.suffix
  separator       = local.effective_naming.separator
  component_order = local.effective_naming.component_order
  clean_input     = local.effective_naming.clean_input
  validate        = local.effective_naming.validate
}
EOF

    # Si ya tiene azurecaf, preservar la configuración existente
    if [ "$has_azurecaf" = "true" ]; then
        cat >> "$naming_file" << EOF

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "main_resource" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "$resource_type"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}
EOF
    else
        cat >> "$naming_file" << EOF

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "main_resource" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "$resource_type"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}
EOF
    fi

    cat >> "$naming_file" << EOF

# Final name resolution with priority
locals {
  final_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? module.local_naming[0].result : (
      local.use_azurecaf ? azurecaf_name.main_resource[0].result : local.base_name
    )
  )

  # Naming method for debugging/monitoring
  naming_method = local.use_passthrough ? "passthrough" : (
    local.use_local_module ? "local_module" : (
      local.use_azurecaf ? "azurecaf" : "fallback"
    )
  )

  # Additional metadata for governance and debugging
  naming_config = {
    effective_naming    = local.effective_naming
    allow_override      = local.allow_individual_override
    resource_type       = local.resource_type
    base_name          = local.base_name
    final_name         = local.final_name
    naming_method      = local.naming_method
  }
}
EOF
}

# Función para actualizar providers.tf
update_providers() {
    local module_path="$1"
    local providers_file="$module_path/providers.tf"
    
    if [ ! -f "$providers_file" ]; then
        return 0
    fi
    
    # Verificar si ya tiene azurecaf provider
    if grep -q "azurecaf" "$providers_file"; then
        return 0
    fi
    
    # Agregar azurecaf provider si no existe
    if grep -q "required_providers" "$providers_file"; then
        # Insertar azurecaf provider en required_providers existente
        sed -i '/required_providers {/,/}/ {
            /azurerm = {/a\
    azurecaf = {\
      source  = "aztfmod/azurecaf"\
      version = "~> 1.2.0"\
    }
        }' "$providers_file"
    fi
}

# Función para actualizar outputs
update_outputs() {
    local module_path="$1"
    local output_file=""
    
    # Buscar archivo de outputs (puede ser outputs.tf o output.tf)
    if [ -f "$module_path/outputs.tf" ]; then
        output_file="$module_path/outputs.tf"
    elif [ -f "$module_path/output.tf" ]; then
        output_file="$module_path/output.tf"
    else
        return 0
    fi
    
    # Verificar si ya tiene outputs de naming
    if grep -q "naming_method" "$output_file"; then
        return 0
    fi
    
    # Agregar outputs de naming
    cat >> "$output_file" << EOF

# Hybrid naming outputs
output "name" {
  value       = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value       = local.naming_method
  description = "The naming method used for this resource (passthrough, local_module, azurecaf, or fallback)"
}

output "naming_config" {
  value       = local.naming_config
  description = "Complete naming configuration metadata for debugging and governance"
}
EOF
}

# Función para actualizar resource principal para usar local.final_name
update_main_resource() {
    local module_path="$1"
    local resource_type="$2"
    
    # Buscar archivos que contengan el recurso principal
    local resource_files=$(grep -l "resource \"$resource_type\"" "$module_path"/*.tf 2>/dev/null || true)
    
    for file in $resource_files; do
        # Reemplazar name = var.settings.name con name = local.final_name
        sed -i 's/name\s*=\s*var\.settings\.name/name = local.final_name/g' "$file"
        
        # Reemplazar name = azurecaf_name.*.result con name = local.final_name
        sed -i 's/name\s*=\s*azurecaf_name\.[^.]*\.result/name = local.final_name/g' "$file"
    done
}

# Función principal para procesar un módulo
process_module() {
    local module_path="$1"
    local module_name=$(basename "$module_path")
    
    log "${BLUE}📋 Procesando módulo: $module_name${NC}"
    
    # Verificar si tiene recursos nombrados
    if ! has_named_resources "$module_path"; then
        log "${YELLOW}⏭️  Saltando $module_name - No tiene recursos nombrados${NC}"
        return 0
    fi
    
    # Detectar tipo de recurso
    local resource_type=$(detect_resource_type "$module_path")
    log "   Tipo de recurso detectado: $resource_type"
    
    # Verificar si ya tiene azurecaf
    local has_azurecaf="false"
    if has_azurecaf_naming "$module_path"; then
        has_azurecaf="true"
        log "   ✅ Módulo con azurecaf existente"
    else
        log "   📝 Módulo sin azurecaf - implementación nueva"
    fi
    
    # Verificar si ya tiene naming.tf híbrido
    if [ -f "$module_path/naming.tf" ] && grep -q "effective_naming" "$module_path/naming.tf"; then
        log "${GREEN}✅ $module_name ya tiene sistema híbrido implementado${NC}"
        return 0
    fi
    
    # Generar naming.tf híbrido
    log "   🔧 Generando naming.tf híbrido..."
    generate_hybrid_naming "$module_path" "$resource_type" "$has_azurecaf"
    
    # Actualizar providers.tf
    log "   🔌 Actualizando providers.tf..."
    update_providers "$module_path"
    
    # Actualizar outputs
    log "   📤 Actualizando outputs..."
    update_outputs "$module_path"
    
    # Actualizar recurso principal
    log "   🎯 Actualizando recurso principal..."
    update_main_resource "$module_path" "$resource_type"
    
    log "${GREEN}✅ $module_name procesado exitosamente${NC}"
    echo "$module_name: ✅ HYBRID NAMING IMPLEMENTED $(date)" >> "$PROGRESS_DIR/progress.log"
}

# Función principal
main() {
    log "${BLUE}🚀 Iniciando implementación del sistema híbrido de naming${NC}"
    
    # Crear directorio de progreso si no existe
    mkdir -p "$PROGRESS_DIR"
    
    # Contador de módulos
    local total_modules=0
    local processed_modules=0
    local skipped_modules=0
    local already_implemented=0
    
    # Procesar todos los módulos
    for category_dir in "$MODULES_DIR"/*; do
        if [ ! -d "$category_dir" ]; then
            continue
        fi
        
        log "${YELLOW}📁 Categoría: $(basename "$category_dir")${NC}"
        
        # Verificar si es un módulo directo o contiene submódulos
        if [ -f "$category_dir/main.tf" ] || [ -f "$category_dir/$(basename "$category_dir").tf" ]; then
            # Es un módulo directo
            total_modules=$((total_modules + 1))
            if process_module "$category_dir"; then
                processed_modules=$((processed_modules + 1))
            else
                skipped_modules=$((skipped_modules + 1))
            fi
        else
            # Contiene submódulos
            for module_dir in "$category_dir"/*; do
                if [ ! -d "$module_dir" ]; then
                    continue
                fi
                
                total_modules=$((total_modules + 1))
                if process_module "$module_dir"; then
                    processed_modules=$((processed_modules + 1))
                else
                    skipped_modules=$((skipped_modules + 1))
                fi
            done
        fi
    done
    
    # Resumen final
    log "${GREEN}🎉 Implementación completada${NC}"
    log "📊 Resumen:"
    log "   Total de módulos analizados: $total_modules"
    log "   Módulos procesados: $processed_modules"
    log "   Módulos saltados: $skipped_modules"
    log ""
    log "📋 Próximos pasos:"
    log "   1. Revisar los logs en: $LOG_FILE"
    log "   2. Probar algunos módulos actualizados"
    log "   3. Actualizar ejemplos con naming = { use_local_module = true }"
    log "   4. Ejecutar tests para validar la implementación"
}

# Ejecutar script principal
main "$@"
