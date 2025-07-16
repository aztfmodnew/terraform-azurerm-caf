# Production environment - azurecaf naming with random
variable "environment" {
  default = "prod"
}

# This will use azurecaf naming for production
# Resources will include random suffix for uniqueness
