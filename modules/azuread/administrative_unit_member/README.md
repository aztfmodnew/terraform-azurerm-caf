# Administrative unit membership

`settings.administrative_unit_object` and `settings.member_object` accept
`id`, or a CAF `key` with optional `lz_key`. `member_object.resource_type`
selects `azuread_groups` or `azuread_users` for key-based lookup.
Direct IDs take precedence; missing required references fail explicitly.
Optional `settings.timeouts` accepts `create`, `read` and `delete`.
The root already passes settings and all supported dependency collections.
The membership `id` is exported.

Do not combine this resource with inline administrative-unit members for the
same unit. Group membership may also require ignoring changes to
`administrative_unit_ids` on the group, as described by the
[AzureAD resource documentation](https://registry.terraform.io/providers/hashicorp/azuread/3.10.0/docs/resources/administrative_unit_member).

## Verification

From the repository root:

```shell
terraform -chdir=examples init -backend=false -input=false -test-directory=tests/unit/azuread/administrative_unit_member
terraform -chdir=examples test -test-directory=tests/unit/azuread/administrative_unit_member -no-color
terraform -chdir=examples test -test-directory=tests/mock -var-file=azuread/101-azuread_administrative_unit_member/configuration.tfvars -no-color
```

Contracts assert direct/key-based resolution and timeouts. Mock plans do not
establish Graph permissions or tenant acceptance.
