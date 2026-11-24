# APIM AI backend pool routing

This 400-level example composes the generic APIM API, policy, policy-fragment, and named-value modules with the new managed-identity AI backend and backend-pool modules. It contains no keys or valid Entra credentials and can therefore be used with mocked planning tests.

## Safety and substitution

- Use HTTPS AI endpoints. The `.invalid` endpoints are symbolic and must be replaced before deployment.
- APIM must have the configured user- or system-assigned identity, and that identity needs an appropriate AI account data-plane role. Replace the symbolic `ai-identity-client-id` value with the selected identity's real client ID; it is an identifier, not a secret.
- `authentication-managed-identity` is intentionally stored in a policy fragment because ARM's backend body has no managed-identity field.
- JWT issuer/audience and request limits are ordinary named-value placeholders. For production secrets, use the existing named-value `value_from_key_vault` contract; never put a key in `value`.
- Trace events are restricted to route, HTTP status, elapsed latency, event name, and the caller-provided correlation header. They never read or emit model input or output content.
- The request-count rate limit is an intentionally simple per-request control.

## Deploy and validate

1. Select a target landing zone and configure Azure authentication.
2. Replace the symbolic AI endpoints, APIM publisher values, JWT values, and role assignments.
3. Keep `openai` local auth disabled and grant `Cognitive Services OpenAI User` (or the service-appropriate role) to the APIM identity.
4. Plan the root module with this directory's `configuration.tfvars`.
5. Verify the API policy references the generated backend-pool name and tests the JWT issuer.
6. Destroy the test environment after validation.

Products and subscriptions are deliberately outside this routing example; they belong to a separate access-contract layer.
