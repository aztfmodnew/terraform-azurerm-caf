# Palo Alto NGFW with Local Rulestack Module Examples

This directory contains examples of how to use the `palo_alto/cloudngfw` module.

## Example Structure

Examples are organized into directories based on complexity level and scenario:

-   **`100-basic-ngfw-with-local-rulestack/`**: Demonstrates a basic setup of the NGFW with a local rulestack, primarily using default values and minimal configurations.
-   **(Future) `200-ngfw-with-custom-rules-and-profiles/`**: Will demonstrate more advanced configurations, including custom rules, security profiles, etc.

## How to Run Examples

1.  Ensure you have Terraform installed and configured for Azure.
2.  Navigate to the root `/examples` directory in your terminal:
    ```bash
    cd /path/to/terraform-azurerm-caf/examples
    ```
3.  Initialize Terraform:
    ```bash
    terraform init
    ```
4.  Apply the desired example configuration using the corresponding `.tfvars` file. For example, to run the basic example:
    ```bash
    terraform apply -var-file=./palo_alto/cloudngfw/100-basic-cloudngfw-with-local-rulestack/configuration.tfvars
    ```

## Prerequisites

-   Azure credentials configured.
-   Active Azure subscription.
-   (If applicable) Dependent resources already provisioned if the example requires them (e.g., an existing VNet if not created as part of the example).
