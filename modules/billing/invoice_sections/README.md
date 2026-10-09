# Billing invoice sections

AzAPI sends invoice-section tags under `properties.tags`. Existing `labels`,
inherited tags and explicit `tags` are merged, with explicit tags taking
precedence. `display_name` defaults to `name`; `state`, `reason_code`,
`target_cloud` and CRUD `timeouts` are optional. Schema validation is enabled.

Billing account and profile identifiers must refer to a billing scope accessible
to the deployment identity; subscription access alone does not establish this.
Mock plans do not verify billing permissions. Follow the
[shared test guide](../../../examples/tests/README.md) when selecting an existing
billing example and its variable files.
