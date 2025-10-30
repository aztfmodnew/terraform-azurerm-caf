# Fabric Capacity examples

These scenarios demonstrate how to provision Azure Fabric Capacity resources with the CAF module set. Each subdirectory contains a `configuration.tfvars` file that can be combined with the root `examples` module to deploy or validate the scenario.

## Available scenarios

| Scenario                    | Description                                                                                                                            |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `100-basic-fabric-capacity` | Creates a single Fabric Capacity using CAF naming conventions, assigns administrative members, and applies inherited plus custom tags. |

## How to run

From the `examples` directory:

```bash
terraform_with_var_files --dir fabric_capacity/100-basic-fabric-capacity --action plan --auto auto --workspace example
```

Replace `plan` with `apply` or `destroy` as needed once validation looks good.
