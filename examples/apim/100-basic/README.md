# Basic API Management with legacy configuration names

This Developer-tier example exercises the retained `enable_http2` and
`enable_backend_*` / `enable_frontend_*` settings. The module maps them to the
AzureRM 5.9.0 `http2_enabled`, `backend_*_enabled` and `frontend_*_enabled` arguments.
HTTP/2 is enabled; SSL 3.0, TLS 1.0 and TLS 1.1 remain disabled.

Current argument names are also accepted and take precedence when both forms
are supplied. The focused compatibility tests cover that precedence.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/apim/100-basic/configuration.tfvars \
  -verbose
```

Custom-domain certificate settings are not exercised by this example; use
the separate custom-domain example for certificate and identity integration.
