# Managed instance failover group

The read-write failover policy defaults to `Manual`. `grace_minutes` is sent
only for `Automatic` mode. An explicit `readonly_endpoint_failover_policy`
string takes precedence over the legacy
`readonly_endpoint_failover_policy_enabled` boolean, which maps to
`Enabled` or `Disabled`. CRUD `timeouts` are optional.

Use existing failover configurations with the
[shared test guide](../../../../examples/tests/README.md); mock plans do not
verify replication or failover. The existing two-region example's workflow
selection includes legacy AzureAD role references to empty module collections;
that separate configuration issue must be resolved before that selection can
serve as a passing integration test. Do not conceal it with mock overrides.
