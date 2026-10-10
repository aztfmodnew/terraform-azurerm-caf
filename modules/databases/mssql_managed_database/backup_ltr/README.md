# Managed database long-term retention

The standalone AzAPI update retains CamelCase retention settings and supports
CRUD `timeouts`. Unset optional properties are filtered out of the update body;
do not add `ignore_null_property` without confirming support for the update
resource kind.

Test through the parent database's existing scenario using the
[shared test guide](../../../../examples/tests/README.md). Mock plans do not
verify backup creation, retention enforcement or restore availability.
