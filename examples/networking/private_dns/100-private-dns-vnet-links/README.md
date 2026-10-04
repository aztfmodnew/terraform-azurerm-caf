# Private DNS records and VNet links

This example covers A, AAAA, CNAME, MX, PTR, SRV and TXT records, an integrated
zone/VNet link, and a standalone reverse-zone/VNet link. AzureRM 5.8 uses the
zone ARM ID for records and links; existing CAF record settings and zone keys
remain unchanged.

Standalone link settings also accept `private_dns_zone_id` or `id`. Existing
name-based settings remain supported with `private_dns_zone_name` and
`resource_group_name`, which CAF resolves through a zone data lookup.

The records demonstrate configuration and do not represent running services.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/networking/private_dns/100-private-dns-vnet-links/configuration.tfvars \
  -verbose
```
