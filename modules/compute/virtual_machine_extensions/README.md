# Virtual machine extensions

The AzAPI status lookup performs GET `instanceView` and exports `statuses` for
extension preconditions. `extension.instance_view_timeouts.read` controls the
lookup timeout; `instance_view_statuses` exposes runtime status.
Existing extension settings and running-state gates remain unchanged.

Mock status responses validate planning, not the VM's real running state or
extension execution. Use the existing [shared test guide](../../../examples/tests/README.md)
and the relevant VM example's complete variable files; do not create a separate
status-only scenario merely to duplicate a plan.
