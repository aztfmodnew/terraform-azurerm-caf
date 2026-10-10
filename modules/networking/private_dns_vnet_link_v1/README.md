# Private DNS VNet links

Entries in `settings.private_dns_zones` accept `resolution_policy` (`Default`
or `NxDomainRedirect`) and CRUD `timeouts`; module-level `settings.timeouts`
provides a fallback. Direct DNS-zone IDs, key references, tag inheritance and
the `registration_enabled = false` default remain supported.
The existing `ids` output is retained; `links` exposes a keyed resource map.

Initialize examples, then run from the repository root:

```shell
terraform -chdir=examples test -test-directory=tests/mock -var-file=networking/private_dns_vnet_link/100_pvtdns_vnetlink/configuration.tfvars
```

The focused timeout-precedence contract (an explicit null entry timeout falls
back to `settings.timeouts`; a non-null entry timeout wins) is opt-in:

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/networking/private_dns_vnet_link_v1
terraform -chdir=examples test -test-directory=tests/unit/networking/private_dns_vnet_link_v1 -no-color
```

This verifies mock planning, not DNS resolution behavior. See the
[test guide](../../../examples/tests/README.md).
