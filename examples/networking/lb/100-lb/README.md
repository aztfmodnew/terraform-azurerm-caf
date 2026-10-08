# Standalone and integrated Load Balancer rule compatibility

This example covers the preferred standalone `lb_*` modules and the existing
integrated `load_balancers` module. It exercises legacy `enable_floating_ip`
and `enable_tcp_reset` settings alongside current `floating_ip_enabled` and
`tcp_reset_enabled` settings. Current names take precedence, including explicit
`false` values.

Integrated outbound rules specify a map of `frontend_ip_configuration` entries
inside each rule. CAF resolves the frontend configuration from that rule, not
from the entire outbound-rule collection.

No VMs are created. The backend address is an example address inside the VNet;
this validates Load Balancer configuration rather than application traffic.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/networking/lb/100-lb/configurations.tfvars \
  -verbose
```
