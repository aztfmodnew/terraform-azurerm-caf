#!/usr/bin/env python3
"""Validate the API Center implementation against official ARM OpenAPI."""

from __future__ import annotations

import json
from pathlib import Path
import sys
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parents[3]
SPEC_URL = (
    "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/"
    "specification/apicenter/resource-manager/Microsoft.ApiCenter/ApiCenter/"
    "stable/2024-03-01/apicenter.json"
)
IDENTITY_URL = (
    "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/main/"
    "specification/common-types/resource-management/v5/managedidentity.json"
)


def fail(message: str) -> None:
    raise AssertionError(message)


def resolve(spec: dict, node: dict) -> dict:
    ref = node.get("$ref")
    if not ref:
        return node
    if not ref.startswith("#/"):
        return node
    target: object = spec
    for part in ref[2:].split("/"):
        target = target[part]
    return dict(target)  # type: ignore[arg-type]


def validate_value(spec: dict, schema: dict, value: object, path: str) -> None:
    schema = resolve(spec, schema)
    for parent in schema.get("allOf", []):
        validate_value(spec, parent, value, path)

    expected_type = schema.get("type")
    if expected_type == "object" and not isinstance(value, dict):
        fail(f"{path}: expected object")
    if expected_type == "array" and not isinstance(value, list):
        fail(f"{path}: expected array")
    if expected_type == "string" and not isinstance(value, str):
        fail(f"{path}: expected string")
    if expected_type == "boolean" and not isinstance(value, bool):
        fail(f"{path}: expected boolean")

    if isinstance(value, dict):
        missing = set(schema.get("required", [])) - set(value)
        if missing:
            fail(f"{path}: missing required fields {sorted(missing)}")
        for key, child in value.items():
            child_schema = schema.get("properties", {}).get(key)
            if child_schema:
                validate_value(spec, child_schema, child, f"{path}.{key}")
    if isinstance(value, list) and "items" in schema:
        for index, child in enumerate(value):
            validate_value(spec, schema["items"], child, f"{path}[{index}]")

    enum = schema.get("enum")
    if enum is not None and value not in enum:
        fail(f"{path}: {value!r} is not one of {enum!r}")


def load_json(url: str) -> dict:
    with urlopen(url, timeout=30) as response:
        return json.load(response)


def main() -> int:
    spec = load_json(SPEC_URL)
    definitions = spec["definitions"]

    expected_types = [
        "Microsoft.ApiCenter/services@2024-03-01",
        "Microsoft.ApiCenter/services/workspaces@2024-03-01",
        "Microsoft.ApiCenter/services/workspaces/environments@2024-03-01",
        "Microsoft.ApiCenter/services/workspaces/apis@2024-03-01",
        "Microsoft.ApiCenter/services/workspaces/apis/versions@2024-03-01",
        "Microsoft.ApiCenter/services/workspaces/apis/versions/definitions@2024-03-01",
        "Microsoft.ApiCenter/services/workspaces/apis/deployments@2024-03-01",
        "Microsoft.ApiCenter/services/metadataSchemas@2024-03-01",
    ]
    module_source = "\n".join(
        path.read_text()
        for path in sorted((ROOT / "modules/integration/api_center").glob("*.tf"))
    )
    for resource_type in expected_types:
        if resource_type not in module_source:
            fail(f"module does not declare exact type {resource_type}")
    if "2024-06-01-preview" in module_source:
        fail("preview ARM API literals must not reach the module implementation")

    expected_paths = [
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/workspaces/{workspaceName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/workspaces/{workspaceName}/environments/{environmentName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/workspaces/{workspaceName}/apis/{apiName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/workspaces/{workspaceName}/apis/{apiName}/versions/{versionName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/workspaces/{workspaceName}/apis/{apiName}/versions/{versionName}/definitions/{definitionName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/workspaces/{workspaceName}/apis/{apiName}/deployments/{deploymentName}",
        "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/"
        "Microsoft.ApiCenter/services/{serviceName}/metadataSchemas/{metadataSchemaName}",
    ]
    for path in expected_paths:
        if path not in spec["paths"]:
            fail(f"official stable spec lacks {path}")

    fixtures = {
        "ServiceProperties": {},
        "WorkspaceProperties": {"title": "Default", "description": "Catalog"},
        "EnvironmentProperties": {
            "title": "Production",
            "kind": "production",
            "server": {
                "type": "Azure API Management",
                "managementPortalUri": ["https://portal.example.invalid"],
            },
            "onboarding": {
                "instructions": "Request access",
                "developerPortalUri": ["https://developer.example.invalid"],
            },
            "customProperties": {"owner": "ai"},
        },
        "ApiProperties": {
            "title": "AI Chat",
            "kind": "rest",
            "description": "AI API",
            "summary": "Chat",
            "termsOfService": {"url": "https://example.invalid/terms"},
            "externalDocumentation": [
                {"title": "Docs", "description": "Guide", "url": "https://example.invalid/docs"}
            ],
            "contacts": [{"name": "Owner", "url": "https://example.invalid", "email": "owner@example.invalid"}],
            "license": {"name": "MIT", "identifier": "MIT"},
            "customProperties": {"owner": "ai"},
        },
        "ApiVersionProperties": {"title": "Version 1", "lifecycleStage": "production"},
        "ApiDefinitionProperties": {"title": "OpenAPI", "description": "Contract"},
        "ApiSpecImportRequest": {
            "value": "{\"openapi\":\"3.0.0\",\"info\":{\"title\":\"AI\",\"version\":\"1\"},\"paths\":{}}",
            "format": "inline",
            "specification": {"name": "openapi", "version": "3.0"},
        },
        "DeploymentProperties": {
            "title": "Production",
            "description": "APIM",
            "environmentId": "/environments/production",
            "definitionId": "/definitions/openapi",
            "state": "active",
            "server": {"runtimeUri": ["https://gateway.example.invalid"]},
            "customProperties": {"owner": "ai"},
        },
        "MetadataSchemaProperties": {
            "schema": "{\"type\":\"object\"}",
            "assignedTo": [{"entity": "api", "required": True, "deprecated": False}],
        },
    }
    for definition, fixture in fixtures.items():
        validate_value(spec, definitions[definition], fixture, definition)

    identity_spec = load_json(IDENTITY_URL)
    identity_type = identity_spec["definitions"]["ManagedServiceIdentity"]["properties"]["type"]
    supported = resolve(identity_spec, identity_type).get("enum", [])
    for identity in ("SystemAssigned", "UserAssigned", "SystemAssigned,UserAssigned"):
        if identity not in supported:
            fail(f"official identity schema does not support {identity}")

    print("API Center ARM schema checks passed for stable 2024-03-01.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:  # keep CI diagnostics concise
        print(f"API Center ARM schema check failed: {error}", file=sys.stderr)
        raise
