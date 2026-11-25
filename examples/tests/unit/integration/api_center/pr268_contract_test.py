#!/usr/bin/env python3
"""Focused source contracts for the PR 268 APIM and deployment fixes."""

from pathlib import Path
import re
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[5]
EXAMPLE = (
    ROOT
    / "examples/apim/500-ai-gateway-api-center-access-contract/configuration.tfvars"
)
ROOT_APIM = ROOT / "api_management.tf"


def block(source: str, marker: str) -> str:
    start = source.index(marker)
    end = source.index("\n}", start) + 2
    return source[start:end]


def main() -> int:
    example = EXAMPLE.read_text()
    root_apim = ROOT_APIM.read_text()

    subscription = block(example, "api_management_subscription = {")
    assert re.search(r'state\s*=\s*"submitted"', subscription)

    api_policy = block(example, "api_management_api_policy = {")
    xml = re.search(r"xml_content\s*=\s*<<-XML\n(?P<xml>.*?)\n\s*XML", api_policy, re.S)
    assert xml, "the API policy fixture must contain an inline XML policy"
    policy = ET.fromstring(xml.group("xml"))
    backend = policy.find("backend")
    assert backend is not None
    assert [child.tag for child in backend] == ["forward-request"]

    assert re.search(
        r'module "api_management_product_policy" \{.*?depends_on = \[\s*'
        r"module\.api_management_product,\s*module\.api_management_policy_fragment",
        root_apim,
        re.S,
    )
    assert re.search(
        r'module "api_management_api_policy" \{.*?module\.api_management_backend_pool',
        root_apim,
        re.S,
    )
    assert re.search(
        r'module "api_management_subscription" \{.*?depends_on = '
        r"\[module\.api_management_product\]",
        root_apim,
        re.S,
    )

    print("PR 268 APIM policy, subscription, and dependency contracts passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
