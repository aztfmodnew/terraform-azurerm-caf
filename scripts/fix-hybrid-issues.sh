#!/bin/bash

# Script para corregir problemas de implementación híbrida
# Corrige: outputs duplicados, errores de sintaxis, y referencias del módulo naming

set -e

LOG_FILE="logs/fix-hybrid-issues.log"
mkdir -p logs

echo "🔧 Iniciando corrección de problemas de implementación híbrida..."
echo "📋 Log: $LOG_FILE"

# Función para log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 1. Corregir outputs duplicados
log "🔧 Corrigiendo outputs duplicados..."
for module_dir in modules/*; do
    if [ -d "$module_dir" ]; then
        for submodule in "$module_dir"/*; do
            if [ -d "$submodule" ]; then
                for output_file in "$submodule"/{output.tf,outputs.tf}; do
                    if [ -f "$output_file" ]; then
                        # Verificar si hay outputs duplicados de "name"
                        duplicate_count=$(grep '^output "name"' "$output_file" 2>/dev/null | wc -l)
                        duplicate_count=$(echo "$duplicate_count" | tr -d '[:space:]')
                        
                        if [[ "$duplicate_count" =~ ^[0-9]+$ ]] && [[ "$duplicate_count" -gt 1 ]]; then
                            log "   🔧 Corrigiendo $output_file (duplicados: $duplicate_count)"
                            
                            # Crear backup
                            cp "$output_file" "${output_file}.backup"
                            
                            # Remover outputs duplicados, mantener solo el primero
                            awk '
                            /^output "name"/ { 
                                if (!seen_name) {
                                    seen_name = 1
                                    in_name_block = 1
                                    print
                                    next
                                } else {
                                    in_duplicate = 1
                                    brace_count = 0
                                    next
                                }
                            }
                            /^output "naming_method"/ { 
                                if (!seen_naming_method) {
                                    seen_naming_method = 1
                                    in_naming_method_block = 1
                                    print
                                    next
                                } else {
                                    in_duplicate = 1
                                    brace_count = 0
                                    next
                                }
                            }
                            in_duplicate {
                                if (/\{/) brace_count++
                                if (/\}/) {
                                    brace_count--
                                    if (brace_count <= 0) {
                                        in_duplicate = 0
                                    }
                                }
                                next
                            }
                            { print }
                            ' "$output_file" > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"
                        fi
                    fi
                done
            fi
        done
    fi
done

# 2. Corregir errores de sintaxis en naming.tf
log "🔧 Corrigiendo errores de sintaxis en naming.tf..."

# Problema específico en container_app_environment
container_env_naming="/home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/modules/compute/container_app_environment/naming.tf"
if [ -f "$container_env_naming" ]; then
    log "   🔧 Corrigiendo sintaxis en container_app_environment/naming.tf"
    
    # Verificar si hay problema de sintaxis
    if grep -q "zurecaf, and local module" "$container_env_naming"; then
        cp "$container_env_naming" "${container_env_naming}.backup"
        
        # Corregir el archivo completo
        cat > "$container_env_naming" << 'EOF'
# Hybrid naming system for azurerm_container_app_environment
# Supports three naming methods: passthrough, azurecaf, and local module

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
  resource_type = "azurerm_container_app_environment"
  
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

# azurecaf naming (conditional - for backward compatibility)
resource "azurecaf_name" "cae" {
  count = local.use_azurecaf ? 1 : 0

  name          = local.base_name
  resource_type = "azurerm_container_app_environment"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  use_slug      = var.global_settings.use_slug
  clean_input   = var.global_settings.clean_input
  separator     = var.global_settings.separator
  random_length = var.global_settings.random_length
  random_seed   = var.global_settings.random_seed
  passthrough   = var.global_settings.passthrough
}

# Final name resolution with priority
locals {
  final_name = local.use_passthrough ? local.base_name : (
    local.use_local_module ? module.local_naming[0].result : (
      local.use_azurecaf ? azurecaf_name.cae[0].result : local.base_name
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
        log "   ✅ container_app_environment/naming.tf corregido"
    fi
fi

# 3. Verificar que el módulo naming local funcione correctamente
log "🔧 Verificando módulo naming local..."
naming_module_path="/home/fdr001/source/github/aztfmodnew/terraform-azurerm-caf/modules/naming"
if [ ! -f "$naming_module_path/main.tf" ]; then
    log "   ❌ Módulo naming no encontrado en $naming_module_path"
    exit 1
else
    log "   ✅ Módulo naming encontrado"
fi

# 4. Corregir referencias incorrectas de rutas en naming.tf
log "🔧 Corrigiendo rutas de módulo naming..."
find modules -name "naming.tf" -type f | while read -r naming_file; do
    # Obtener la profundidad del directorio para calcular la ruta relativa correcta
    depth=$(echo "$naming_file" | tr '/' '\n' | wc -l)
    
    if [ "$depth" -eq 3 ]; then
        # modules/category/naming.tf -> ../../naming
        correct_path="../../naming"
    elif [ "$depth" -eq 4 ]; then
        # modules/category/module/naming.tf -> ../../naming  
        correct_path="../../naming"
    else
        # Profundidad inesperada, asumir 2 niveles
        correct_path="../../naming"
    fi
    
    # Verificar si la ruta es incorrecta
    if grep -q 'source = "../naming"' "$naming_file"; then
        log "   🔧 Corrigiendo ruta en $naming_file"
        sed -i 's|source = "../naming"|source = "../../naming"|g' "$naming_file"
    fi
done

log "✅ Corrección de problemas completada"
log "📋 Próximos pasos:"
log "   1. Revisar archivos .backup si hay problemas"
log "   2. Probar terraform init en ejemplos"
log "   3. Ejecutar plan para verificar"

echo "🎉 Corrección completada. Ver logs en: $LOG_FILE"
