# Group membership composition

Existing name, direct object ID, local key and cross-landing-zone key modes are
preserved. `settings.timeouts` passes create/read/delete durations to each
membership resource. Collection entries in `azuread_groups`,
`azuread_service_principals`, `managed_identities` and `mssql_servers` can override
the durations with their own `timeouts`. Explicit null on an entry leaves provider
defaults in effect.

`group_id` takes precedence over legacy `group_object_id` for direct membership
calls; omitted `group_id` now correctly falls back rather than passing null.
For key-based membership composition, destination-group keys are resolved as
before. Do not mix inline group `members` and standalone memberships for the
same destination.

The root exports `azuread_groups_members` and `azuread_groups_membership`.
Membership module outputs preserve keys by resolution mode. In the independent
root membership map, an entry's `key` selects the destination group; the map
entry name need not match that group key.

## Local verification

From the repository root:

```shell
terraform -chdir=examples init -backend=false -input=false -test-directory=tests/unit/azuread/group_members
terraform -chdir=examples test -test-directory=tests/unit/azuread/group_members -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=azuread/104-azuread-group-membership/configuration.tfvars -no-color
```

Focused contracts assert member IDs, collection resolution and timeout propagation.
Mocks do not verify Graph permissions or real tenant membership changes.
