# Scripts de Implementación del Sistema Híbrido de Naming

Este directorio contiene scripts automatizados para implementar el sistema híbrido de naming en todos los módulos de Terraform CAF.

## 📋 Scripts Disponibles

### 1. `analyze-naming-status.sh` - Análisis Previo
Analiza el estado actual de todos los módulos y genera un reporte detallado.

```bash
./scripts/analyze-naming-status.sh
```

**Output:**
- Lista todos los módulos con su estado actual
- Identifica módulos con/sin azurecaf existente
- Cuenta recursos nombrados vs no nombrados
- Proporciona estimación de tiempo para implementación

### 2. `test-hybrid-naming.sh` - Pruebas Específicas
Permite probar la implementación en módulos específicos antes de ejecutar masivamente.

```bash
# Ver módulos disponibles
./scripts/test-hybrid-naming.sh --list

# Dry run (solo mostrar cambios)
./scripts/test-hybrid-naming.sh --dry-run storage/storage_account

# Probar módulo específico
./scripts/test-hybrid-naming.sh compute/container_app_environment

# Probar múltiples módulos
./scripts/test-hybrid-naming.sh cognitive_services/ai_services storage/storage_account
```

### 3. `implement-hybrid-naming.sh` - Implementación Masiva
Implementa el sistema híbrido en todos los módulos automáticamente.

```bash
./scripts/implement-hybrid-naming.sh
```

## 🔄 Flujo de Trabajo Recomendado

### Paso 1: Análisis Inicial
```bash
./scripts/analyze-naming-status.sh
```
Revisa el output para entender cuántos módulos necesitan actualización.

### Paso 2: Pruebas Controladas
```bash
# Dry run para ver cambios
./scripts/test-hybrid-naming.sh --dry-run storage/storage_account

# Probar algunos módulos críticos
./scripts/test-hybrid-naming.sh compute/container_app_environment
./scripts/test-hybrid-naming.sh cognitive_services/ai_services
```

### Paso 3: Validación Manual
Revisar los módulos probados:
- Verificar que `naming.tf` se creó correctamente
- Comprobar que `providers.tf` incluye azurecaf
- Validar outputs de naming
- Ejecutar `terraform plan` en ejemplos

### Paso 4: Implementación Masiva
```bash
./scripts/implement-hybrid-naming.sh
```

### Paso 5: Validación Post-Implementación
- Revisar logs en `/examples/.tmp-hybrid-naming-progress/deployment.log`
- Probar algunos módulos con terraform plan
- Actualizar ejemplos con `naming = { use_local_module = true }`

## 🎯 Qué Hace Cada Script

### Analyze Script
- ✅ Escanea todos los módulos en `/modules`
- ✅ Identifica recursos con atributo `name`
- ✅ Detecta presencia de `azurecaf_name`
- ✅ Clasifica módulos por estado actual
- ✅ Genera reporte con estimaciones

### Test Script  
- ✅ Permite testing granular por módulo
- ✅ Modo dry-run para preview de cambios
- ✅ Crea backups automáticos
- ✅ Detecta tipo de recurso principal
- ✅ Valida prerequisitos antes de procesar

### Implementation Script
- ✅ Procesa todos los módulos automáticamente
- ✅ Genera `naming.tf` con sistema híbrido completo
- ✅ Actualiza `providers.tf` para incluir azurecaf
- ✅ Agrega outputs de naming y debugging
- ✅ Actualiza recursos principales para usar `local.final_name`
- ✅ Maneja módulos con/sin azurecaf existente
- ✅ Logging completo del proceso
- ✅ Tracking de progreso

## 🔧 Características del Sistema Híbrido

### Para Módulos CON azurecaf Existente
- ✅ Preserva configuración azurecaf existente
- ✅ Agrega soporte para local_module
- ✅ Implementa governance con `allow_resource_override`
- ✅ Mantiene backward compatibility

### Para Módulos SIN azurecaf
- ✅ Implementa sistema completo desde cero
- ✅ Agrega azurecaf provider
- ✅ Configura naming = { use_local_module = true } por defecto
- ✅ Sistemas de fallback completos

### Governance Híbrida
```hcl
# En locals.tf global
naming = {
  use_azurecaf              = true     # Método por defecto
  use_local_module          = false    # Nuevo método
  allow_resource_override   = true     # Control de governance
  
  # Patrones específicos por recurso
  resource_patterns = {
    azurerm_storage_account = {
      separator = ""  # Sin separador para storage
    }
  }
}

# En tfvars individuales
my_resource = {
  name = "example"
  naming = {
    prefix = "custom"      # Override individual
    separator = "_"        # Override individual
  }
}
```

## 📊 Outputs Generados

Cada módulo actualizado tendrá estos outputs:

```hcl
output "name" {
  value = local.final_name
  description = "The name of the resource"
}

output "naming_method" {
  value = local.naming_method
  description = "Method used: passthrough, local_module, azurecaf, or fallback"
}

output "naming_config" {
  value = local.naming_config
  description = "Complete naming metadata for debugging and governance"
}
```

## ⚠️ Consideraciones Importantes

### Antes de Ejecutar
1. **Backup**: Los scripts crean backups automáticos, pero considera backup manual
2. **Testing**: Siempre probar con algunos módulos primero
3. **Dependencies**: Verificar que el módulo `/modules/naming` existe

### Durante la Ejecución
1. **Logs**: Monitorear logs en tiempo real
2. **Errores**: Los scripts se detienen en errores críticos
3. **Progreso**: El progreso se guarda en `.tmp-hybrid-naming-progress/`

### Después de Ejecutar
1. **Validación**: Probar módulos actualizados con terraform plan
2. **Ejemplos**: Actualizar archivos `.tfvars` en examples/
3. **Documentación**: Actualizar READMEs de módulos si necesario

## 🚀 Comandos Rápidos

```bash
# Análisis completo
./scripts/analyze-naming-status.sh

# Prueba específica
./scripts/test-hybrid-naming.sh storage/storage_account

# Implementación completa
./scripts/implement-hybrid-naming.sh

# Ver progreso
tail -f examples/.tmp-hybrid-naming-progress/deployment.log
```
