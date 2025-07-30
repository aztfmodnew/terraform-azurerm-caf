# Premium and Special Quota Services

This directory contains examples for Azure services that require special quotas, approvals, or significant resource allocation that may not be available in standard Azure subscriptions.

## Services Requiring Special Quotas

### Azure VMware Solution (AVS)

- **Examples**: `compute/vmware_cluster/*`
- **Requirements**:
  - Azure VMware Solution quota (requires Microsoft approval)
  - Minimum 3 nodes per cluster
  - Dedicated hardware allocation
  - Special networking requirements
- **Typical Use Cases**: Enterprise hybrid cloud, VMware migration to Azure
- **Testing**: Not suitable for automated CI/CD testing due to quota and cost constraints

## Running Premium Examples

These examples should only be run in environments where:

1. **Special quotas have been approved** by Microsoft Azure support
2. **Sufficient budget** is allocated (these services are typically high-cost)
3. **Manual testing** is acceptable (not suitable for automated pipelines)

## Alternative Testing Approaches

For CI/CD and automated testing, consider:

1. **Mock Testing**: Use the mock test directory to validate configuration without deployment
2. **Terraform Plan Only**: Run `terraform plan` to validate syntax and configuration
3. **Manual Testing**: Deploy manually in development/staging environments with appropriate quotas

## Requesting Special Quotas

To request special quotas for Azure VMware Solution:

1. Open an Azure Support ticket
2. Select "Service and subscription limits (quotas)"
3. Select "Azure VMware Solution" as the quota type
4. Provide business justification and expected usage
5. Allow 3-5 business days for approval

## Cost Considerations

These services typically have high minimum costs:

- **Azure VMware Solution**: $10,000+ per month minimum
- **Dedicated Hosts**: $1,000+ per month per host
- **Large GPU instances**: $500+ per month

Always review pricing before deployment.
