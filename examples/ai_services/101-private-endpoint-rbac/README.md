# AI Services private endpoint and RBAC

This scenario creates an AI Services account with public access disabled while
preserving its explicit `Deny` network ACL. The private endpoint defaults to the
`account` subresource and joins DNS records into the Cognitive Services, OpenAI,
and Azure AI (`services.ai`) private DNS zones.

The role mapping demonstrates both supported AI Gateway principal styles:

- APIM's system-assigned managed identity through `api_management`
- A keyed user-assigned identity through `managed_identities`
- A legacy direct principal ID through `object_ids`

The example is exercised by the shared mock scenario runner. Mock planning
validates references and provider schema only; it does not prove Azure
DNS/resolution or deployment behavior.
