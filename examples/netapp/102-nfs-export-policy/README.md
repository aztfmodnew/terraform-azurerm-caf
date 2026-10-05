# NetApp NFS export policy

The example retains `protocols_enabled` export-rule inputs. AzureRM 5.8 receives
these through `protocol`; an explicit current `protocol` setting takes
precedence. The third rule demonstrates the current input alongside the legacy
input.

The example explicitly asks AzureRM to register `Microsoft.NetApp`. AzureRM 5
defaults to no automatic resource-provider registration; the caller must have
subscription permissions to register this namespace. Other examples retain
the empty additional-registration list by default.

The default provider behavior protects volumes from deletion. For a disposable
test lifecycle, explicitly set:

```hcl
provider_azurerm_features_netapp = {
  prevent_volume_destruction = false
}
```

Do not disable deletion protection for production data. Live deployment
requires NetApp capacity in the selected region and creates capacity pools
billed independently from used volume space.

```bash
terraform -chdir=./examples test \
  -test-directory=./tests/mock \
  -var-file=../examples/netapp/102-nfs-export-policy/configuration.tfvars \
  -verbose
```
