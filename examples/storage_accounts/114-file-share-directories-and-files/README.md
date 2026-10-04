# File-share directories and files

This self-contained example creates a file share, a directory and files at the
root and inside the directory. It reuses the small file fixtures from the
existing backup example and does not provision Azure Backup dependencies.
Run Terraform from the examples directory so fixture paths resolve correctly.

AzureRM 5.8 requires `storage_share_url` for directory and file resources.
CAF's directory submodule retains its legacy `storage_share_id` alias for
callers that already pass a share URL; an explicit `storage_share_url` takes
precedence. The file submodule retains its `share_id` input, also carrying a URL.
The parent share module supplies these values, so existing nested configurations
and resource addresses remain unchanged.

Mock validation from the repository root:

```bash
terraform -chdir=examples test -test-directory=tests/mock \
  -var-file=./storage_accounts/114-file-share-directories-and-files/configuration.tfvars
```

Validated against the AzureRM 5.8 schemas for
[directories](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/storage_share_directory)
and [files](https://registry.terraform.io/providers/hashicorp/azurerm/5.8.0/docs/resources/storage_share_file).
