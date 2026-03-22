#!/usr/bin/env python3
"""
FarmerApp — Claude AI Triage
==============================
Sends test results + crash logs to Claude for automated root-cause analysis.
Outputs: docs/testing/reports/<timestamp>/claude_triage.md

Usage:
  python3 scripts/claude_triage.py <report_dir>

Requires:
  pip3 install anthropic
  export ANTHROPIC_API_KEY=sk-ant-...
"""

import sys
import json
import os
from pathlib import Path

try:
    import anthropic
except ImportError:
    print("⚠️  anthropic package not found. Run: pip3 install anthropic")
    sys.exit(1)


TRIAGE_PROMPT = """You are a senior mobile QA engineer analyzing an automated UI test report for FarmerApp — a Flutter-based agricultural marketplace app for Indian farmers.

The app has these main features:
- Phone OTP login (Firebase Auth)
- Animal listing marketplace (buy/sell cattle, goats, etc.)
- Transport booking for animal logistics
- Veterinary appointment booking
- Direct messaging between farmers
- 4 languages: English, Hindi, Marathi, Punjabi

Here are the test results:

## Test Summary
{summary}

## Failed Flows
{failures}

## Crash / ANR Log Lines (from logcat)
{crashes}

## Maestro Runner Output (last portion)
{log_tail}

---

Please analyze and respond with:

### 1. Root Cause Analysis
For each failed flow, identify:
- **Likely cause**: widget not found / timing / network / real bug / env issue
- **Category**: FLAKY (timing/environment, will auto-fix on retry) vs REAL_BUG (code needs fixing)

### 2. Crash Analysis
For each crash/ANR line:
- Which screen/feature is likely responsible
- Whether it is a known Flutter issue or app-specific

### 3. Priority Action List
Ordered by impact:
- P0 🔴 — App crash, blocks all users
- P1 🟠 — Feature broken, blocks a user journey
- P2 🟡 — Flaky test, low user impact
- P3 🟢 — Minor / cosmetic

### 4. Suggested Fixes
For each REAL_BUG, describe:
- Which file/screen needs attention
- What the likely code fix is

Keep your response concise and actionable. Use markdown formatting."""


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 claude_triage.py <report_dir>")
        sys.exit(1)

    report_dir = Path(sys.argv[1])
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not api_key:
        print("❌ ANTHROPIC_API_KEY environment variable not set")
        sys.exit(1)

    # Read inputs
    summary_path = report_dir / "summary.json"
    crash_path = report_dir / "crashes.txt"
    log_path = report_dir / "maestro.log"
    xml_path = report_dir / "results.xml"

    summary_text = summary_path.read_text() if summary_path.exists() else "No summary available"
    crash_text = crash_path.read_text(errors="replace")[:3000] if crash_path.exists() else "No crash data"
    log_tail = log_path.read_text(errors="replace")[-4000:] if log_path.exists() else "No log data"

    # Build failures text from XML
    failures_text = ""
    if xml_path.exists():
        import xml.etree.ElementTree as ET
        try:
            tree = ET.parse(xml_path)
            for tc in tree.getroot().iter("testcase"):
                f = tc.find("failure") or tc.find("error")
                if f is not None:
                    msg = (f.text or f.get("message", ""))[:600]
                    failures_text += f"\n**{tc.get('classname', '')} / {tc.get('name', '')}**\n```\n{msg}\n```\n"
        except Exception:
            pass

    if not failures_text:
        failures_text = "No failures recorded."

    prompt = TRIAGE_PROMPT.format(
        summary=summary_text,
        failures=failures_text,
        crashes=crash_text,
        log_tail=log_tail,
    )

    print("🤖 Sending test results to Claude for triage analysis...")

    client = anthropic.Anthropic(api_key=api_key)
    message = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=3000,
        messages=[{"role": "user", "content": prompt}],
    )

    triage_md = message.content[0].text
    output_path = report_dir / "claude_triage.md"
    output_path.write_text(triage_md, encoding="utf-8")

    print(f"\n✅ Triage report written to: {output_path}")
    print("\n" + "─" * 60)
    print(triage_md[:2000])
    if len(triage_md) > 2000:
        print(f"\n... (truncated — see {output_path} for full report)")


if __name__ == "__main__":
    main()
