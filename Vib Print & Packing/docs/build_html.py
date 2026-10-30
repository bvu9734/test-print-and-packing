"""Generate MVP-Introduction.html from MVP-Introduction.md.

Usage (from the app folder "Vib Print & Packing"):
    python -m pip install markdown   # once
    python docs/build_html.py
"""

from pathlib import Path

import markdown

DOCS_DIR = Path(__file__).resolve().parent
SOURCE = DOCS_DIR / "MVP-Introduction.md"
TARGET = DOCS_DIR / "MVP-Introduction.html"

TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>
  :root {{
    --accent: #0b5cad;
    --border: #d0d7de;
    --muted: #57606a;
    --stripe: #f6f8fa;
  }}
  body {{
    font-family: "Segoe UI", Arial, sans-serif;
    line-height: 1.55;
    color: #1f2328;
    max-width: 1000px;
    margin: 0 auto;
    padding: 32px 24px 64px;
  }}
  h1 {{ color: var(--accent); border-bottom: 3px solid var(--accent); padding-bottom: 8px; }}
  h2 {{ color: var(--accent); border-bottom: 1px solid var(--border); padding-bottom: 4px; margin-top: 40px; }}
  h3 {{ margin-top: 28px; }}
  table {{ border-collapse: collapse; width: 100%; margin: 12px 0 20px; font-size: 0.95em; }}
  th, td {{ border: 1px solid var(--border); padding: 6px 10px; vertical-align: top; }}
  th {{ background: #eaf1fb; text-align: left; }}
  tr:nth-child(even) td {{ background: var(--stripe); }}
  code {{ background: #eff1f3; padding: 1px 5px; border-radius: 4px; font-size: 0.9em; }}
  pre {{ background: #f6f8fa; border: 1px solid var(--border); padding: 12px; border-radius: 6px; overflow-x: auto; }}
  pre code {{ background: none; padding: 0; }}
  blockquote {{
    margin: 16px 0;
    padding: 8px 16px;
    border-left: 4px solid var(--accent);
    background: #f1f6fd;
    color: var(--muted);
  }}
  hr {{ border: none; border-top: 1px solid var(--border); margin: 32px 0; }}
  a {{ color: var(--accent); }}
  @media print {{
    body {{ max-width: none; padding: 0; }}
    h2 {{ page-break-after: avoid; }}
    table, blockquote {{ page-break-inside: avoid; }}
  }}
</style>
</head>
<body>
{body}
</body>
</html>
"""


def main() -> None:
    source_text = SOURCE.read_text(encoding="utf-8")
    title = source_text.splitlines()[0].lstrip("# ").strip()
    body = markdown.markdown(
        source_text,
        extensions=["tables", "toc", "fenced_code", "sane_lists"],
        output_format="html5",
    )
    TARGET.write_text(TEMPLATE.format(title=title, body=body), encoding="utf-8")
    print(f"Generated {TARGET}")


if __name__ == "__main__":
    main()
