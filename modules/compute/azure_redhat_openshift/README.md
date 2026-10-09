# Azure Red Hat OpenShift

Existing cluster, master, worker, ingress and API-server settings remain supported.
Additional network settings are `network_profile.outbound_type`,
`network_profile.preconfigured_nsg` and
`network_profile.load_balancer_profile.managed_outbound_ips.count`.

`identity` accepts `type`, direct `identity_ids`, local `managed_identity_keys`
and `remote.<lz_key>.managed_identity_keys`, resolved through
`combined_resources.managed_identities`.
`platform_workload_identity_profile` accepts `upgradeable_to` and a
`platform_workload_identities` map. Entries accept `resource_id` or
`managed_identity = { key, lz_key }`; direct IDs take precedence.

Identity-only configurations do not read service-principal secrets. Existing
direct and Key Vault-backed service principals remain supported. CRUD `timeouts`
retain the `60m` create default. Response outputs include `identity`,
`api_server_profile`, `console_profile` and `ingress_profiles`, without exposing
service-principal or pull secrets. Provisioning state and console endpoints are
response fields, not writable settings.

Initialize examples, then run from the repository root:

```shell
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=compute/azure_redhat_openshift/101_basic_private_cluster/aro.tfvars \
  -var-file=compute/azure_redhat_openshift/101_basic_private_cluster/principal.tfvars \
  -var-file=compute/azure_redhat_openshift/101_basic_private_cluster/vnet.tfvars
```

The public example uses the same three file names under
`102_basic_public_cluster`; run it separately. Mock plans do not verify cluster
provisioning or connectivity. See the [test guide](../../../examples/tests/README.md).
