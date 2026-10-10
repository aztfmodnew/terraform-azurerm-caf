# Key-based group memberships

The existing collections resolve group/service-principal object IDs,
managed-identity principal IDs and SQL-server RBAC IDs. `members.keys` selects
members; `group_object_id` identifies the destination group.
Optional `timeouts` applies create/read/delete durations to every membership.
Existing collection keys and resource addresses remain unchanged.

The parent supports per-collection timeouts with fallback to `settings.timeouts`.
No update timeout is available in the
[AzureAD group-member resource](https://registry.terraform.io/providers/hashicorp/azuread/3.10.0/docs/resources/group_member).
