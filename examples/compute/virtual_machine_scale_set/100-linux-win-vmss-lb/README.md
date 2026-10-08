# Linux and Windows scale sets with load balancers

This example creates one Linux and one Windows scale set with independent load
balancers. Regular-priority instances avoid relying on Spot capacity.

The Linux NIC uses legacy `enable_ip_forwarding`; the Windows NIC uses
`ip_forwarding_enabled` alongside an old false value to demonstrate current-name
precedence. Linux automatic upgrade settings use legacy names, including the
inverted rollback flag. Windows supplies both naming forms. Automatic OS
upgrades remain disabled.

Standard disks retain compatibility with older configurations containing
performance settings: these settings are ignored unless the disk type is
`PremiumV2_LRS` or `UltraSSD_LRS`. For supported disk types, current
`disk_iops_read_write` and `disk_mbps_read_write` take precedence over legacy
`ultra_ssd_*` names.

```bash
terraform -chdir=./examples test -test-directory=./tests/mock \
  -var-file=../examples/compute/virtual_machine_scale_set/100-linux-win-vmss-lb/configuration.tfvars \
  -verbose
```

Use unique naming prefixes and isolated state for live plan/apply/destroy.
Ultra SSD, Premium SSD v2, and the autoscaled Linux variant require separate
deployment coverage; this basic example does not create those configurations.
