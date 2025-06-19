## You need to register in your tenant the well-known GUID for AADDS. If you have permissions you can do it with this code or ask the directory team to do it first
## https://docs.microsoft.com/en-us/azure/active-directory-domain-services/alert-service-principal#recreate-a-missing-service-principal

azuread_service_principals = {
  aadds = {
    azuread_application = {
      client_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36"
    }
  }
}

### The principal running this Terraform deployment must be Global Admin to deploy AADDS101-active_directory_domain_service-replica-Vnet2Vnet
