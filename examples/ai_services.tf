## AI Services module has moved inside the example wrapper module to improve graph processing.
## The moved instruction is supported in Terraform 1.1+ and can be removed after a couple of releases.
moved {
  from = module.ai_services
  to   = module.example.module.ai_services
}
