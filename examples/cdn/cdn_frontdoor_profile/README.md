# Ejemplos para el módulo cdn_frontdoor_profile

Este directorio contiene ejemplos de uso para el módulo `cdn_frontdoor_profile`.

- **100-basic-default/**: Ejemplo básico de un perfil Front Door con recursos mínimos.
- **200-full-setup/**: Ejemplo avanzado con dominios personalizados, endpoints, orígenes, reglas, etc.

## Cómo ejecutar los ejemplos

1. Ve al directorio `/examples`.
2. Ejecuta:

```bash
terraform init
terraform apply -var-file=./cdn/cdn_frontdoor_profile/100-basic-default/configuration.tfvars
```

O para el ejemplo avanzado:

```bash
terraform apply -var-file=./cdn/cdn_frontdoor_profile/200-full-setup/configuration.tfvars
```

## Prerrequisitos
- Tener configurado el backend y providers en `/examples`.
- Variables necesarias definidas en `variables.tf`.
