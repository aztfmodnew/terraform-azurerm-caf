# Site-to-site VPN gateway connection

The connection demonstrates legacy `enable_bgp = false`, mapped to AzureRM's
`bgp_enabled`. The current `bgp_enabled` setting takes precedence when supplied.

```bash
terraform -chdir=./examples test -test-directory=./tests/mock \
  -var-file=../examples/networking/virtual_network_gateway/103-vpn-site-to-site-connection/configuration.tfvars \
  -verbose
```

The remote gateway address and shared key are demonstration values. Replace
them with your own configuration for a working VPN tunnel. A successful
plan/apply/destroy verifies Azure resource creation and settings, not
connectivity to an on-premises device. Keep real shared keys out of source
control and protect Terraform state.
