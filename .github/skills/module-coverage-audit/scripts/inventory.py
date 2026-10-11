#!/usr/bin/env python3
"""Generate a deterministic inventory of Terraform-bearing module directories."""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path
from typing import TextIO


BLOCK_PATTERN = re.compile(
    r'^\s*(resource|data)\s+"([^"]+)"\s+"[^"]+"',
    re.MULTILINE,
)
MODULE_PATTERN = re.compile(r'^\s*module\s+"([^"]+)"', re.MULTILINE)
HEREDOC_START_PATTERN = re.compile(r"<<[-~]?([A-Za-z_][A-Za-z0-9_]*)\s*$")
BLOCK_COMMENT_PATTERN = re.compile(r"/\*.*?\*/", re.DOTALL)
LINE_COMMENT_PATTERN = re.compile(r"(^|\s)(#|//).*$", re.MULTILINE)
EXCLUDED_PARTS = {".git", ".terraform"}
FIELDS = [
    "path",
    "depth",
    "classification",
    "terraform_role",
    "provider_families",
    "managed_resource_types",
    "data_source_types",
    "child_module_calls",
    "audit_status",
    "gap_decision",
    "implementation_status",
    "test_status",
    "stack_pr",
]
PROGRESS_FIELDS = {
    "audit_status",
    "gap_decision",
    "implementation_status",
    "test_status",
    "stack_pr",
}


def find_module_directories(modules_root: Path) -> list[Path]:
    directories = set()
    for terraform_file in modules_root.rglob("*.tf"):
        relative_parts = terraform_file.relative_to(modules_root).parts
        if any(part in EXCLUDED_PARTS or part.startswith(".") for part in relative_parts):
            continue
        directories.add(terraform_file.parent)
    return sorted(directories)


def classify(directory: Path, modules_root: Path) -> str:
    depth = len(directory.relative_to(modules_root).parts)
    if depth == 1:
        return "shared-candidate"
    if depth == 2:
        return "root-candidate"
    return "nested-candidate"


def strip_non_code(source: str) -> str:
    """Remove comments and heredoc bodies so block scanning only sees HCL code."""
    source = BLOCK_COMMENT_PATTERN.sub("", source)
    source = LINE_COMMENT_PATTERN.sub("", source)

    lines = source.splitlines()
    kept: list[str] = []
    terminator: str | None = None
    for line in lines:
        if terminator is None:
            kept.append(line)
            match = HEREDOC_START_PATTERN.search(line)
            if match:
                terminator = match.group(1)
        elif line.strip() == terminator:
            terminator = None
    return "\n".join(kept)


def collect_inventory(modules_root: Path) -> list[dict[str, str | int]]:
    rows = []
    for directory in find_module_directories(modules_root):
        resources: set[str] = set()
        data_sources: set[str] = set()
        module_calls: set[str] = set()

        for terraform_file in sorted(directory.glob("*.tf")):
            source = strip_non_code(terraform_file.read_text(encoding="utf-8"))
            for block_kind, block_type in BLOCK_PATTERN.findall(source):
                if block_kind == "resource":
                    resources.add(block_type)
                else:
                    data_sources.add(block_type)
            module_calls.update(MODULE_PATTERN.findall(source))

        all_types = resources | data_sources
        providers = {resource_type.split("_", 1)[0] for resource_type in all_types}
        if resources:
            terraform_role = "resource-bearing"
        elif data_sources:
            terraform_role = "data-only"
        else:
            terraform_role = "composition-or-helper"

        rows.append(
            {
                "path": directory.relative_to(modules_root.parent).as_posix(),
                "depth": len(directory.relative_to(modules_root).parts),
                "classification": classify(directory, modules_root),
                "terraform_role": terraform_role,
                "provider_families": ",".join(sorted(providers)),
                "managed_resource_types": ",".join(sorted(resources)),
                "data_source_types": ",".join(sorted(data_sources)),
                "child_module_calls": ",".join(sorted(module_calls)),
                "audit_status": "pending",
                "gap_decision": "",
                "implementation_status": "not-started",
                "test_status": "not-started",
                "stack_pr": "",
            }
        )
    return rows


def preserve_progress(
    rows: list[dict[str, str | int]],
    existing_inventory: TextIO,
) -> list[dict[str, str | int]]:
    previous_rows = csv.DictReader(existing_inventory, delimiter="\t")
    progress_by_path = {
        row["path"]: row
        for row in previous_rows
        if row.get("path")
    }
    for row in rows:
        previous = progress_by_path.get(str(row["path"]), {})
        for field in PROGRESS_FIELDS:
            if field in previous and previous[field] is not None:
                row[field] = previous[field]
    return rows


def write_inventory(rows: list[dict[str, str | int]], stream: TextIO) -> None:
    writer = csv.DictWriter(stream, fieldnames=FIELDS, delimiter="\t", lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)


def main() -> int:
    repository_root = Path(__file__).resolve().parents[4]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=repository_root,
        help="Repository root containing modules/ (default: inferred from this script).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Output TSV file; omit to write to standard output.",
    )
    arguments = parser.parse_args()

    modules_root = arguments.root.resolve() / "modules"
    if not modules_root.is_dir():
        parser.error(f"Expected a modules/ directory under repository root: {arguments.root}")

    rows = collect_inventory(modules_root)
    if arguments.output:
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        if arguments.output.is_file():
            with arguments.output.open(encoding="utf-8", newline="") as existing:
                rows = preserve_progress(rows, existing)
        with arguments.output.open("w", encoding="utf-8", newline="") as stream:
            write_inventory(rows, stream)
    else:
        write_inventory(rows, sys.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
