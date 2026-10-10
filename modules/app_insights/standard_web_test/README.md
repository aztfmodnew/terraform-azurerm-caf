# Standard availability tests

The AzAPI web test sends both top-level `kind` and `properties.Kind`.
Optional settings include `ignore_http_status_code`, `configuration.web_test`
and CRUD `timeouts`. Existing defaults and raw ARM `content_validation`
properties (`ContentMatch`, `IgnoreCase`, `PassIfTextFound`) remain supported.
Unset optional request and validation fields are omitted.

From the repository root, test the existing example with the shared runner:

```shell
terraform -chdir=examples test -test-directory=tests/mock -var-file=app_insights/103-web-test/configuration.tfvars
```

Initialize examples first. This checks mock plan generation, not execution of
the availability test in Azure. See the [test guide](../../../examples/tests/README.md).
