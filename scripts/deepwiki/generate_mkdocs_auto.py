
import argparse
import json
import os
import re
import sys
import subprocess
from typing import List, Tuple, Dict, Any

try:
    import hcl2
except ImportError as exc:  # pragma: no cover - import guard
    raise SystemExit(
        "python-hcl2 is required. Install it with 'pip install python-hcl2'."
    ) from exc


# -----------------------------
# Helpers: filesystem + writing
# -----------------------------

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
MODULES_ROOT = os.path.join(REPO_ROOT, "modules")
DOCS_ROOT = os.path.join(REPO_ROOT, "docs")
DOCS_MODULES = os.path.join(DOCS_ROOT, "modules")
DOCS_ROOT_AGG = os.path.join(DOCS_ROOT, "root")


def ensure_dir(path: str):
    os.makedirs(path, exist_ok=True)


def write(path: str, text: str):
    ensure_dir(os.path.dirname(path))
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)

def write_if_absent(path: str, text: str):
    """Write file only if it doesn't already exist (preserve manual edits)."""
    if not os.path.exists(path):
        write(path, text)


def clean_module_dot_files(modules_root: str) -> int:
    """
    Remove legacy per-module graph.dot files under modules/**/graph.dot.
    Returns number of files deleted.
    """
    deleted = 0
    for root, _dirs, files in os.walk(modules_root):
        for fn in files:
            if fn == "graph.dot":
                fp = os.path.join(root, fn)
                try:
                    os.remove(fp)
                    deleted += 1
                except Exception:
                    # Best-effort cleanup; ignore failures
                    pass
    return deleted


# -----------------------------
# Parsing Terraform to a simple graph
# -----------------------------

def read_tf_from_folder(folder: str) -> str:
    content = ""
    for fn in sorted(os.listdir(folder)):
        if fn.endswith(".tf"):
            with open(os.path.join(folder, fn), "r", encoding="utf-8", errors="ignore") as f:
                content += "\n" + f.read()
    return content


def _find_block_body(content: str, start: int) -> Tuple[str, int]:
    depth = 1
    i = start
    while i < len(content):
        char = content[i]
        if char == '{':
            depth += 1
        elif char == '}':
            depth -= 1
            if depth == 0:
                return content[start:i], i + 1
        i += 1
    return content[start:], len(content)


def _extract_blocks(content: str) -> List[Dict[str, str]]:
    pattern = re.compile(r'(resource|module|data)\s+"([^"]+)"(?:\s+"([^"]+)")?\s*\{', re.MULTILINE)
    blocks: List[Dict[str, str]] = []
    idx = 0
    while True:
        match = pattern.search(content, idx)
        if not match:
            break
        kind = match.group(1)
        primary = match.group(2)
        secondary = match.group(3)
        body, end_idx = _find_block_body(content, match.end())

        if kind == "resource":
            if not secondary:
                idx = end_idx
                continue
            node = f"{primary}.{secondary}"
        elif kind == "data":
            if not secondary:
                idx = end_idx
                continue
            node = f"data.{primary}.{secondary}"
        else:  # module
            node = f"module.{primary}"

        blocks.append({"kind": kind, "node": node, "body": body})
        idx = end_idx

    return blocks


def extract_dependencies_from_content(content: str):
    blocks = _extract_blocks(content)
    nodes = {block["node"] for block in blocks}
    edges = set()
    
    # Track remote_objects dependencies (external/implicit)
    remote_deps = set()

    for block in blocks:
        body = block["body"]
        source = block["node"]

        # Module references
        for module_name in re.findall(r'module\.([A-Za-z0-9_]+)', body):
            target = f"module.{module_name}"
            if target in nodes and target != source:
                edges.add((source, target))

        # Data source references
        for data_type, data_name in re.findall(r'data\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)', body):
            target = f"data.{data_type}.{data_name}"
            if target in nodes and target != source:
                edges.add((source, target))

        # Resource references
        for res_type, res_name in re.findall(r'([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)', body):
            if res_type in {"var", "local", "each", "toset", "try", "coalesce", "path", "lookup", "length"}:
                continue
            candidate = f"{res_type}.{res_name}"
            if candidate in nodes and candidate != source:
                edges.add((source, candidate))
        
        # Remote objects dependencies (CAF pattern)
        # Captures: var.remote_objects.resource_type or var.remote_objects.resource_types
        for remote_obj in re.findall(r'var\.remote_objects\.([A-Za-z0-9_]+)', body):
            remote_deps.add(f"remote:{remote_obj}")
    
    # Add remote_objects as virtual nodes if any dependencies found
    if remote_deps:
        nodes = nodes.union(remote_deps)
        for remote_node in remote_deps:
            # Find all sources that reference this remote object
            for block in blocks:
                if f"var.remote_objects.{remote_node[7:]}" in block["body"]:
                    edges.add((block["node"], remote_node))

    return nodes, sorted(edges)


def extract_dependencies_path(path: str):
    if os.path.isdir(path):
        content = read_tf_from_folder(path)
    else:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    return extract_dependencies_from_content(content)


def mermaid_block(nodes, edges):
    lines = ["```mermaid", "graph TD"]
    for n in sorted(nodes):
        lines.append(f'    {n}["{n}"]')
    for s, d in edges:
        lines.append(f"    {s} --> {d}")
    lines.append("```")
    return lines


def _module_of_address(address: str) -> str:
    """Return top-level module path for a Terraform address or 'root' if none.
    Examples:
      module.frontend.module.routes.azurerm_cdn_frontdoor_route.r -> module.frontend
      azurerm_resource_group.rg -> root
    """
    m = re.match(r"(module\.[a-zA-Z0-9_]+)(?:\..*)?", address)
    return m.group(1) if m else "root"


def parse_dot_module_edges(dot_text: str) -> Tuple[List[str], List[Tuple[str, str]]]:
    """Aggregate Terraform DOT graph edges to module-level dependencies.
    Returns (modules, edges) where modules is a sorted unique list and edges a unique list of tuples.
    """
    node_edge_re = re.compile(r'\s*"([^"]+)"\s*->\s*"([^"]+)"')
    modules: set[str] = set()
    mod_edges: set[Tuple[str, str]] = set()

    for line in dot_text.splitlines():
        m = node_edge_re.match(line)
        if not m:
            continue
        src_addr, dst_addr = m.group(1), m.group(2)
        src_mod = _module_of_address(src_addr)
        dst_mod = _module_of_address(dst_addr)
        modules.add(src_mod)
        modules.add(dst_mod)
        if src_mod != dst_mod:
            mod_edges.add((src_mod, dst_mod))

    # Ensure stable ordering
    return sorted(modules), sorted(mod_edges)


def generate_root_dependency_map(create_dot: bool = False, update_dot: bool = False) -> Tuple[str, str]:
    """Create root-level terraform graph and a module dependency Mermaid diagram.
    Returns tuple of (dot_md_block, mermaid_md_block) to embed in a page.
    """
    # Ensure terraform init at repo root when needed
    def ensure_root_init(path: str):
        if not os.path.exists(os.path.join(path, ".terraform")):
            print(f"Running 'terraform init' at root {path}...")
            try:
                subprocess.run("terraform init -input=false -no-color", cwd=path, shell=True, check=True)
            except Exception as e:
                print(f"Failed to run 'terraform init' at root: {e}")

    dot_file = os.path.join(DOCS_ROOT, "root", "graph.dot")
    ensure_dir(os.path.dirname(dot_file))
    need_graph = update_dot or (create_dot and not os.path.exists(dot_file)) or not os.path.exists(dot_file)

    dot_content = ""
    if need_graph:
        ensure_root_init(REPO_ROOT)
        try:
            # Write directly to file for traceability
            subprocess.run("terraform graph -draw-cycles > " + dot_file, cwd=REPO_ROOT, shell=True, check=True)
        except Exception as e:
            print(f"Failed to create root graph.dot: {e}")

    # Read DOT content if present
    if os.path.exists(dot_file):
        with open(dot_file, "r", encoding="utf-8", errors="ignore") as f:
            dot_content = f.read().strip()

    dot_block = "\n".join(["```dot", dot_content, "```"]) if dot_content else "No DOT graph available."

    # Build module Mermaid diagram
    modules, mod_edges = parse_dot_module_edges(dot_content) if dot_content else ([], [])

    def safe_mermaid_id(name: str) -> str:
        # Replace disallowed characters for Mermaid identifiers
        ident = re.sub(r"[^a-zA-Z0-9_]", "_", name)
        # Ensure it doesn't start with a digit
        if re.match(r"^[0-9]", ident):
            ident = f"n_{ident}"
        return ident or "root"

    # Map module names to Mermaid-safe ids
    id_map = {m: safe_mermaid_id(m) for m in modules}

    mer_lines = ["```mermaid", "graph LR"]
    for mname in modules:
        mid = id_map[mname]
        mer_lines.append(f'    {mid}["{mname}"]')
    for s, d in mod_edges:
        sid = id_map[s]
        did = id_map[d]
        mer_lines.append(f"    {sid} --> {did}")
    mer_lines.append("```")
    mermaid_block_md = "\n".join(mer_lines) if modules else "No module dependencies detected."

    # Write a consolidated page
    page = [
        "# Root dependency map",
        "",
        "## Module dependency diagram (Mermaid)",
        mermaid_block_md,
        "",
        "## Full Terraform graph (DOT)",
        dot_block,
    ]
    write(os.path.join(DOCS_ROOT, "root", "dependency_map.md"), "\n".join(page) + "\n")

    return dot_block, mermaid_block_md


def _strip_interpolation(value: Any) -> Any:
    if isinstance(value, str) and value.startswith("${") and value.endswith("}"):
        return value[2:-1].strip()
    return value


def _stringify_value(value: Any) -> str:
    value = _strip_interpolation(value)
    if value is None:
        return ""
    if isinstance(value, str):
        return value.strip()
    try:
        return json.dumps(value, ensure_ascii=False, sort_keys=True)
    except TypeError:
        return str(value)


def _clean_multiline(text: str) -> str:
    if not text:
        return ""
    return " ".join(text.strip().split())


def _flatten_block(block: Any) -> Dict[str, Any]:
    if isinstance(block, dict):
        return block
    if isinstance(block, list) and block:
        if isinstance(block[0], dict):
            return block[0]
    return {}


def extract_variables(module_path: str) -> List[Dict[str, Any]]:
    """Return variable metadata parsed via python-hcl2."""
    var_file = os.path.join(module_path, "variables.tf")
    variables: List[Dict[str, Any]] = []

    if not os.path.exists(var_file):
        return variables

    with open(var_file, "r", encoding="utf-8", errors="ignore") as fp:
        data = hcl2.load(fp)

    for entry in data.get("variable", []):
        for name, attrs in entry.items():
            block = _flatten_block(attrs)
            description = _clean_multiline(_stringify_value(block.get("description")))
            var_type = _stringify_value(block.get("type", "any")) or "any"
            default_present = "default" in block
            default_value = _stringify_value(block.get("default")) if default_present else ""

            validation_entries = block.get("validation", [])
            validations: List[str] = []
            for validation in validation_entries:
                validation_block = _flatten_block(validation)
                error_message = _clean_multiline(
                    _stringify_value(validation_block.get("error_message"))
                )
                condition = _clean_multiline(
                    _stringify_value(validation_block.get("condition"))
                )
                if error_message:
                    validations.append(error_message)
                elif condition:
                    validations.append(condition)

            variables.append(
                {
                    "name": name,
                    "description": description,
                    "type": var_type,
                    "required": "no" if default_present else "yes",
                    "default": default_value,
                    "validation": "; ".join(validations) if validations else "",
                }
            )

    return variables


def extract_outputs(module_path: str) -> List[Dict[str, Any]]:
    """Return outputs with descriptions from outputs.tf or output.tf."""
    outputs: List[Dict[str, Any]] = []

    for filename in ["outputs.tf", "output.tf"]:
        outputs_file = os.path.join(module_path, filename)
        if not os.path.exists(outputs_file):
            continue

        with open(outputs_file, "r", encoding="utf-8", errors="ignore") as fp:
            data = hcl2.load(fp)

        for entry in data.get("output", []):
            for name, attrs in entry.items():
                block = _flatten_block(attrs)
                description = _clean_multiline(
                    _stringify_value(block.get("description"))
                )
                sensitive = _stringify_value(block.get("sensitive"))
                value_expr = _clean_multiline(_stringify_value(block.get("value")))

                outputs.append(
                    {
                        "name": name,
                        "description": description,
                        "sensitive": sensitive,
                        "value": value_expr,
                    }
                )
        break

    return outputs

def extract_resource_types(module_path: str):
    """Return a sorted list of unique Terraform resource types used in the module."""
    contents = read_tf_from_folder(module_path)
    types = set()
    for m in re.finditer(r'\bresource\s+"([^"]+)"\s+"([^"]+)"', contents):
        types.add(m.group(1))
    return sorted(types)


def format_inputs_table(inputs: list) -> str:
    """Format inputs as a Markdown table."""
    if not inputs:
        return "No inputs defined."

    lines = [
        "| Name | Description | Type | Required | Default | Validation |",
        "|------|-------------|------|:--------:|---------|------------|",
    ]
    for inp in inputs:
        name = inp.get("name", "")
        desc = inp.get("description", "").replace("\n", " ").replace("|", "\\|")
        if len(desc) > 120:
            desc = desc[:117] + "..."
        typ = inp.get("type", "any").replace("|", "\\|")
        if len(typ) > 40:
            typ = typ[:37] + "..."
        required = inp.get("required", "no")
        default = (inp.get("default", "") or "-").replace("|", "\\|")
        validation = (inp.get("validation", "") or "-").replace("|", "\\|")

        lines.append(f"| `{name}` | {desc} | `{typ}` | {required} | `{default}` | {validation} |")

    return "\n".join(lines)


def format_outputs_table(outputs: list) -> str:
    """Format outputs as a Markdown table."""
    if not outputs:
        return "No outputs defined."

    lines = [
        "| Name | Description | Sensitive | Value |",
        "|------|-------------|-----------|-------|",
    ]
    for out in outputs:
        name = out.get("name", "")
        desc = out.get("description", "").replace("\n", " ").replace("|", "\\|")
        if len(desc) > 120:
            desc = desc[:117] + "..."
        sensitive = out.get("sensitive", "") or "-"
        value_expr = (out.get("value", "") or "-").replace("|", "\\|")
        lines.append(f"| `{name}` | {desc} | {sensitive} | `{value_expr}` |")

    return "\n".join(lines)


# -----------------------------
# Generation
# -----------------------------

def generate_modules_docs(create_dot=False, update_dot=False):
    nav_modules = {}
    ensure_dir(DOCS_MODULES)
    
    # Count total modules for progress
    total_modules = sum(1 for cat in os.listdir(MODULES_ROOT) 
                       if os.path.isdir(os.path.join(MODULES_ROOT, cat))
                       for mod in os.listdir(os.path.join(MODULES_ROOT, cat))
                       if os.path.isdir(os.path.join(MODULES_ROOT, cat, mod)))
    current = 0

    for category in sorted(os.listdir(MODULES_ROOT)):
        cat_path = os.path.join(MODULES_ROOT, category)
        if not os.path.isdir(cat_path):
            continue
        for mod in sorted(os.listdir(cat_path)):
            mod_path = os.path.join(cat_path, mod)
            if not os.path.isdir(mod_path):
                continue
            current += 1
            print(f"[{current}/{total_modules}] Processing {category}/{mod}...", end='\r')

            # DOT file logic
            dot_path = os.path.join(mod_path, "graph.dot")
            tf_files = [fn for fn in os.listdir(mod_path) if fn.endswith(".tf")]
            # --create-dot: only create if missing
            def ensure_terraform_init(path):
                if not os.path.exists(os.path.join(path, ".terraform")):
                    print(f"Running 'terraform init' in {path}...")
                    try:
                        subprocess.run("terraform init -input=false -no-color", cwd=path, shell=True, check=True)
                    except Exception as e:
                        print(f"Failed to run 'terraform init' in {path}: {e}")

            if create_dot and not os.path.exists(dot_path) and tf_files:
                ensure_terraform_init(mod_path)
                try:
                    subprocess.run("terraform graph -draw-cycles > graph.dot", cwd=mod_path, shell=True, check=True)
                    print(f"Created DOT file for {category}/{mod}.")
                except Exception as e:
                    print(f"Failed to create DOT file for {category}/{mod}: {e}")
            # --update-dot: always create/overwrite
            if update_dot and tf_files:
                ensure_terraform_init(mod_path)
                try:
                    subprocess.run("terraform graph -draw-cycles > graph.dot", cwd=mod_path, shell=True, check=True)
                    print(f"Updated DOT file for {category}/{mod}.")
                except Exception as e:
                    print(f"Failed to update DOT file for {category}/{mod}: {e}")
            nodes, edges = extract_dependencies_path(mod_path)
            diagram = "\n".join(mermaid_block(nodes, edges)) if nodes else "No dependencies detected."

            # Sources
            sources = [f"`modules/{category}/{mod}/{fn}`" for fn in sorted(os.listdir(mod_path)) if fn.endswith('.tf')]
            res_types = extract_resource_types(mod_path)
            
            # Extract variables and outputs (fast, no subprocess)
            variables = extract_variables(mod_path)
            outputs = extract_outputs(mod_path)

            # Format tables
            inputs_table = format_inputs_table(variables)
            outputs_table = format_outputs_table(outputs)

            md = [
                f"# {category}/{mod}",
                "",
                "## Overview",
                "This page documents the Terraform module implementation, key configuration surfaces, and how it integrates with CAF.",
                "",
                "## Dependency diagram (Mermaid)",
                diagram,
                "",
                "## Module Reference",
                f"**Category**: {category}  ",
                f"**Path**: `modules/{category}/{mod}`  ",
                ("**Azure Resources**: " + ", ".join([f'`{t}`' for t in res_types])) if res_types else "",
                "",
                "### Inputs",
                "",
                inputs_table,
                "",
                "### Outputs",
                "",
                outputs_table,
                "",
                "## Sources",
                "\n".join([f"- {s}" for s in sources]) if sources else "No Terraform sources found.",
            ]
            
            rel_md = os.path.join("modules", category, f"{mod}.md")
            write(os.path.join(DOCS_ROOT, rel_md), "\n".join(md) + "\n")
            nav_modules.setdefault(category, []).append((mod, rel_md.replace(os.sep, '/')))
    
    print(f"\n✅ Processed {current} modules across {len(nav_modules)} categories")

    # Modules index
    idx = ["# Modules index", ""]
    for cat, items in sorted(nav_modules.items()):
        idx.append(f"## {cat}")
        for title, relp in items:
            idx.append(f"- [{title}]({relp})")
        idx.append("")
    write(os.path.join(DOCS_MODULES, "index.md"), "\n".join(idx) + "\n")
    return nav_modules, current


def generate_root_docs():
    ensure_dir(DOCS_ROOT_AGG)
    nav_root = []
    for fn in sorted(os.listdir(REPO_ROOT)):
        if not fn.endswith('.tf'):
            continue
        if fn in ("backend.azurerm",):
            continue
        nodes, edges = extract_dependencies_path(os.path.join(REPO_ROOT, fn))
        diagram = "\n".join(mermaid_block(nodes, edges)) if nodes else "No dependencies detected."
        md = [
            f"# {fn}",
            "",
            "## Overview",
            "Root-level aggregator wiring calling one or more service modules.",
            "",
            "## Dependency diagram",
            diagram,
            "",
            "## Sources",
            f"- `{fn}`",
        ]
        title = os.path.splitext(fn)[0]
        rel_md = os.path.join("root", f"{title}.md")
        write(os.path.join(DOCS_ROOT, rel_md), "\n".join(md) + "\n")
        nav_root.append((title, rel_md.replace(os.sep, '/')))

    # Root index
    idx = ["# Root (aggregators) index", ""]
    for title, relp in nav_root:
        idx.append(f"- [{title}]({relp})")
    write(os.path.join(DOCS_ROOT_AGG, "index.md"), "\n".join(idx) + "\n")
    return nav_root


def generate_home():
    overview_md = """
# Azure CAF Terraform – DeepWiki

This site provides a navigable documentation experience for the CAF Terraform framework:

- Category-based catalog of modules with Mermaid dependency diagrams
- Root-level (aggregator) pages showing how the root ties modules together
- Links to API reference pages per module when available

Use the left navigation to browse categories and pages. Diagrams are rendered with Mermaid.
""".strip()
    write_if_absent(os.path.join(DOCS_ROOT, "index.md"), overview_md + "\n")


def generate_mkdocs_yml(nav_modules, nav_root, force_nav=True):
    lines = [
        "site_name: CAF DeepWiki",
        "theme:",
        "  name: material",
        "nav:",
        "  - Overview: index.md",
        "  - Modules:",
    ]

    for cat, items in sorted(nav_modules.items()):
        lines.append(f"    - {cat}:")
        for title, relp in items:
            lines.append(f"      - {title}: {relp}")
    lines.append("    - Index: modules/index.md")

    lines.append("  - Root:")
    for title, relp in nav_root:
        lines.append(f"    - {title}: {relp}")
    # Add dependency map to root section if it exists
    dep_map_path = os.path.join("root", "dependency_map.md")
    if os.path.exists(os.path.join(DOCS_ROOT, dep_map_path)):
        lines.append(f"    - dependency_map: {dep_map_path}")
    lines.append("    - Index: root/index.md")

    # plugins
    lines += [
        "plugins:",
        "  - search",
        "  - mermaid2",
        "  - mkdocs_graphviz",
        "     #light_theme: 995522",
        "     #dark_theme: chartreuse",
        "     #color: 02f514",
        "     #bgcolor: 0000FF or none",
        "     #graph_color: FF0000",
        "     #graph_fontcolor: 00FF00",
        "     #node_color: FF0000",
        "     #node_fontcolor: 0000FF",
        "     #edge_color: FF0000",
        "     #edge_fontcolor: 00FF00",
        "     #priority: 100"

        "markdown_extensions:",
        "  - admonition",
        "  - toc:",
        "      permalink: true",
    ]
    # Respect manual edits: only create mkdocs.yml if it doesn't exist
    mkdocs_path = os.path.join(REPO_ROOT, "mkdocs.yml")
    if not force_nav and os.path.exists(mkdocs_path):
        return
    write(mkdocs_path, "\n".join(lines) + "\n")


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate MkDocs content for CAF DeepWiki")
    parser.add_argument("--create-dot", action="store_true", help="Create missing graph.dot files using terraform graph")
    parser.add_argument("--update-dot", action="store_true", help="(Re)generate graph.dot files even if they exist")
    parser.add_argument("--clean-module-dots", action="store_true", help="Delete legacy per-module graph.dot files under modules/**")
    parser.add_argument(
        "--force-nav",
        dest="force_nav",
        action="store_true",
        default=True,
        help="Overwrite mkdocs.yml navigation (default)",
    )
    parser.add_argument(
        "--no-force-nav",
        dest="force_nav",
        action="store_false",
        help="Do not overwrite mkdocs.yml if it already exists",
    )
    parser.add_argument(
        "--root-deps",
        dest="root_deps",
        action="store_true",
        default=True,
        help="Generate root-level module dependency map (default)",
    )
    parser.add_argument(
        "--no-root-deps",
        dest="root_deps",
        action="store_false",
        help="Skip generating root-level module dependency map",
    )
    parser.add_argument(
        "--root-graph-update",
        dest="root_graph_update",
        action="store_true",
        help="Force regeneration of root graph.dot",
    )
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv or sys.argv[1:])
    ensure_dir(DOCS_ROOT)
    ensure_dir(DOCS_MODULES)
    ensure_dir(DOCS_ROOT_AGG)
    # Do not manage separate API pages anymore

    # Optional cleanup of legacy per-module DOT files
    if args.clean_module_dots:
        removed = clean_module_dot_files(MODULES_ROOT)
        print(f"Removed {removed} per-module graph.dot files under {MODULES_ROOT}")

    nav_modules, processed_modules = generate_modules_docs(
        create_dot=args.create_dot, update_dot=args.update_dot
    )
    if processed_modules == 0:
        print("❌ No modules processed. Check the modules directory path.", file=sys.stderr)
        sys.exit(1)

    nav_root = generate_root_docs()
    # Optionally generate aggregated root dependency map
    if args.root_deps:
        generate_root_dependency_map(create_dot=True, update_dot=args.root_graph_update)
    generate_home()
    generate_mkdocs_yml(nav_modules, nav_root, force_nav=args.force_nav)
    print(
        "✅ MkDocs site content generated under ./docs and navigation written to mkdocs.yml"
        if args.force_nav
        else "✅ MkDocs site content generated under ./docs (mkdocs.yml left untouched)"
    )


if __name__ == "__main__":
    main()
