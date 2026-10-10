# Single group membership

Required inputs are `group_object_id` and `member_object_id`. Optional
`timeouts` accepts `create`, `read` and `delete`. Membership updates replace
the resource; there is no update timeout. The module exports its membership ID.

Do not manage the same group with both standalone memberships and the group's
inline `members` property.
[AzureAD 3.10.0 schema](https://registry.terraform.io/providers/hashicorp/azuread/3.10.0/docs/resources/group_member).
