# Terraform Test Commands

This README provides an example on how to use locally Terraform test commands.

## Running Tests

### Shared runner and mock data

- `mock/e2e_plan.tftest.hcl` is the shared plan-only runner used by the scenario
  workflows. Supply the existing example's `.tfvars` files; do not create another
  suite merely to plan the same example.
- `mock_data/data.tfmock.hcl` contains shared simulated provider responses, not
  scenarios or assertions. Add defaults only when an example needs them. Use a
  targeted override in the runner when a response must differ for one resource.
- `general.tftest.hcl` is outside the directory selected by
  `-test-directory=./tests/mock`, so those workflow commands do not run it. Its
  empty `run` block defaults to `apply`, and providers without a `mock_provider`
  block are not mocked. Do not treat it as the plan-only CI runner.

The shared runner checks that an example can produce a plan. It does not
currently contain assertions, and mocked responses do not prove that Azure will
accept the configuration. Provider initialization, provider-source resolution,
and AzAPI resource-schema validation must be checked separately.

### Guidelines for module-specific coverage

The existing `mock/`, `mock_data/`, `general.tftest.hcl` and scenario pipelines
remain unchanged by contract-test organization. Additional behavioral tests live
under `unit/<category>/<module>/`, mirroring module names and child paths:

```text
examples/tests/
├── mock/
├── mock_data/
├── general.tftest.hcl
└── unit/
    └── networking/
        └── network_security_perimeter/
            └── contract.tftest.hcl
```

The perimeter path illustrates the naming convention; it does not imply a test
exists for every module. Use `contract.tftest.hcl` for the primary suite and
descriptive names such as `compatibility.tftest.hcl` for distinct coverage.
Existing provider-migration and Event Grid suites are organized by module under
`unit`, not by provider version. Child-resource suites may use additional path
segments. Root integration contracts, such as storage CMK resolution, use their
functional category (`unit/storage/storage_accounts`) and explicitly select
the root module.

#### Contract for new and updated tests

- Add a test only for a concrete assertion or expected validation failure not
  already covered; do not duplicate the shared example plan.
- Select the module under test in each `run`. Local `module.source` paths are
  resolved from the Terraform configuration directory (`examples`), not the
  nested test-file directory. Moving a suite does not change these paths.
- Name runs after the behavior and use explicit `command = plan`. Mock all
  external provider dependencies. Providers not mocked and provisioners are
  not made safe merely by calling the suite a unit test.
- Reuse existing shared mock data where appropriate; keep module-specific
  responses in the suite, without modifying shared defaults for one test.
- Never override the expression/resource behavior being tested. To assert
  computed mock outputs during planning, use `override_during = plan` on the
  relevant mock rather than applying resources.
- Preserve legacy inputs, precedence tests and `expect_failures` when relocating
  suites. Do not replace assertions with plan-success checks.
- Document purpose, coverage limits, prerequisites and the exact local command
  in the module README. These suites are opt-in local checks; organizing them
  does not add them to existing CI or change pipeline selection.
- Keep logs and temporary fixtures in session storage or a verified ignored,
  unsynchronized temporary directory.

#### Running a module contract

From the repository root, for example:

```shell
terraform -chdir=examples init -backend=false -test-directory=tests/unit/storage/storage_accounts
terraform -chdir=examples test -test-directory=tests/unit/storage/storage_accounts -no-color
```

For recovery vault legacy soft-delete validation, select
`tests/unit/recovery_services/recovery_vault`.

Terraform does not recursively discover all nested suites from
`-test-directory=tests/unit`. Select a directory containing test files.
To execute every contract locally without changing pipelines:

```bash
while IFS= read -r directory; do
  directory="${directory#examples/}"
  terraform -chdir=examples init -backend=false -input=false \
    -test-directory="$directory" || exit 1
  terraform -chdir=examples test -test-directory="$directory" -no-color || exit 1
done < <(find examples/tests/unit -name '*.tftest.hcl' -printf '%h\n' | sort -u)
```

The two ASE suites use plan-time mock outputs instead of mock applies, avoiding
execution of the ASE destroy provisioner. Assertions are retained.

#### Existing contract coverage

The relocated suites retain the provider-migration assertions for Front Door
actions/conditions/cache, Cosmos DB authentication, load-balancer aliases,
pipeline metrics spelling, Kusto extensions, IoT recommendations, Key Vault
contacts/null handling, APIM certificate and hostname settings, Container App
grace periods, Event Hub settings, federated identities, storage queues/files,
and Recovery Services legacy soft-delete validation.

ASE deployment output decoding, ASE/ASEv3 DNS references, service-plan references,
removed Linux Web App Ruby runtime rejection, and Event Grid legacy/current
endpoint precedence remain covered. Shared cross-module files were split by
the module selected in each run, retaining their fixtures and assertions.
Storage CMK tests still select the root aggregator and check direct URI
precedence, omitted/null/empty versions, pinned versions, older remote outputs
and sovereign-cloud vault resolution.

These are behavioral contracts, not new deployment scenarios. Provider versions
are selected by repository requirements and the installed lock file; directory
names are not tied to a provider release. See the
[changelog](../../CHANGELOG.md) for migration requirements.

Each module README should identify:

1. The existing examples that exercise the module.
2. The exact shared-runner command, including every required variable file in a
   deterministic order. Do not combine alternative full configurations as if
   they were complementary files; later files override earlier variables.
3. What the tests check and which service-side behavior remains unverified.
4. Any initialization prerequisites or known blockers.

See the [Terraform test configuration](https://developer.hashicorp.com/terraform/language/tests)
and [provider mocking](https://developer.hashicorp.com/terraform/language/tests/mocking)
references for execution and override behavior.

To run tests in Terraform, you can use the following command from the root of the repository:

```bash
terraform -chdir=./examples test \
-test-directory=./tests/mock \
-var-file=../examples/communication/communication_services/101-communication_service/configuration.tfvars \
-verbose
```

It will output the following:
```bash
tests/mock/e2e_plan.tftest.hcl... in progress
  run "test_plan"... pass

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.example.random_string.prefix[0] will be created
  + resource "random_string" "prefix" {
      + id          = (known after apply)
      + length      = 4
      + lower       = true
      + min_lower   = 0
      + min_numeric = 0
      + min_special = 0
      + min_upper   = 0
      + number      = false
      + numeric     = false
      + result      = (known after apply)
      + special     = false
      + upper       = false
    }

  # module.example.module.communication_services["cs1"].azurecaf_name.acs will be created
  + resource "azurecaf_name" "acs" {
      + clean_input   = true
      + id            = (known after apply)
      + name          = "test-acs1-re1"
      + passthrough   = false
      + prefixes      = (known after apply)
      + random_length = 0
      + resource_type = "azurerm_communication_service"
      + result        = (known after apply)
      + results       = (known after apply)
      + separator     = "-"
      + use_slug      = true
    }

  # module.example.module.communication_services["cs1"].azurerm_communication_service.acs will be created
  + resource "azurerm_communication_service" "acs" {
      + data_location               = "United States"
      + id                          = (known after apply)
      + name                        = (known after apply)
      + primary_connection_string   = (known after apply)
      + primary_key                 = (known after apply)
      + resource_group_name         = (known after apply)
      + secondary_connection_string = (known after apply)
      + secondary_key               = (known after apply)
      + tags                        = {
          + "module" = "communication_services"
        }
    }

  # module.example.module.communication_services["cs2"].azurecaf_name.acs will be created
  + resource "azurecaf_name" "acs" {
      + clean_input   = true
      + id            = (known after apply)
      + name          = "test-acs2-re2"
      + passthrough   = false
      + prefixes      = (known after apply)
      + random_length = 0
      + resource_type = "azurerm_communication_service"
      + result        = (known after apply)
      + results       = (known after apply)
      + separator     = "-"
      + use_slug      = true
    }

  # module.example.module.communication_services["cs2"].azurerm_communication_service.acs will be created
  + resource "azurerm_communication_service" "acs" {
      + data_location               = "United States"
      + id                          = (known after apply)
      + name                        = (known after apply)
      + primary_connection_string   = (known after apply)
      + primary_key                 = (known after apply)
      + resource_group_name         = (known after apply)
      + secondary_connection_string = (known after apply)
      + secondary_key               = (known after apply)
      + tags                        = {
          + "module" = "communication_services"
        }
    }

  # module.example.module.resource_groups["rg1"].azurecaf_name.rg will be created
  + resource "azurecaf_name" "rg" {
      + clean_input   = true
      + id            = (known after apply)
      + name          = "rg1"
      + passthrough   = false
      + prefixes      = (known after apply)
      + random_length = 0
      + resource_type = "azurerm_resource_group"
      + result        = (known after apply)
      + results       = (known after apply)
      + separator     = "-"
      + use_slug      = true
    }

  # module.example.module.resource_groups["rg1"].azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "australiacentral"
      + name     = (known after apply)
      + tags     = {
          + "landingzone"   = "examples"
          + "rover_version" = null
        }
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + objects = (sensitive value)

tests/mock/e2e_plan.tftest.hcl... tearing down
tests/mock/e2e_plan.tftest.hcl... pass

Success! 1 passed, 0 failed.

```
