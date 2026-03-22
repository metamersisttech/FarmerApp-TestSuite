#!/usr/bin/env python3
"""
FarmerApp — Accessibility Checker
====================================
Parses uiautomator XML dumps and reports:
  - Clickable widgets with no content-desc (screen reader label)
  - Touch targets smaller than 48x48dp
  - EditText fields with no hint or label

Usage:
  # 1. Dump UI from device for each screen
  adb shell uiautomator dump /sdcard/ui_home.xml
  adb pull /sdcard/ui_home.xml docs/testing/a11y/

  # 2. Run this script
  python3 scripts/check_accessibility.py docs/testing/a11y/
"""

import sys
import glob
from pathlib import Path
from xml.etree import ElementTree as ET

MIN_TOUCH_DP = 48   # Material Design minimum touch target


def parse_bounds(bounds_str: str):
    """Parse '[x1,y1][x2,y2]' → (w, h) in pixels."""
    try:
        coords = bounds_str.replace("][", ",").strip("[]").split(",")
        x1, y1, x2, y2 = int(coords[0]), int(coords[1]), int(coords[2]), int(coords[3])
        return x2 - x1, y2 - y1
    except Exception:
        return 999, 999


def check_file(xml_path: str) -> list[dict]:
    issues = []
    screen = Path(xml_path).stem

    try:
        tree = ET.parse(xml_path)
    except ET.ParseError as e:
        print(f"⚠️  Could not parse {xml_path}: {e}")
        return issues

    for node in tree.getroot().iter("node"):
        cls = node.get("class", "")
        desc = (node.get("content-desc") or "").strip()
        text = (node.get("text") or "").strip()
        clickable = node.get("clickable") == "true"
        focusable = node.get("focusable") == "true"
        bounds = node.get("bounds", "[0,0][0,0]")
        w, h = parse_bounds(bounds)

        # Rule 1: Clickable with no label
        if clickable and not desc and not text:
            issues.append({
                "screen": screen,
                "severity": "HIGH",
                "rule": "No content-desc on clickable widget",
                "class": cls,
                "bounds": bounds,
            })

        # Rule 2: Touch target too small
        if clickable and (w < MIN_TOUCH_DP or h < MIN_TOUCH_DP):
            issues.append({
                "screen": screen,
                "severity": "MEDIUM",
                "rule": f"Touch target {w}x{h}px < {MIN_TOUCH_DP}dp minimum",
                "class": cls,
                "bounds": bounds,
            })

        # Rule 3: EditText/TextField with no hint and no label
        if "EditText" in cls or "TextField" in cls:
            hint = (node.get("hint") or "").strip()
            if not hint and not desc and not text:
                issues.append({
                    "screen": screen,
                    "severity": "MEDIUM",
                    "rule": "EditText has no hint, label, or content-desc",
                    "class": cls,
                    "bounds": bounds,
                })

    return issues


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 check_accessibility.py <xml_dir_or_file>")
        sys.exit(1)

    path = sys.argv[1]
    xml_files = glob.glob(f"{path}/*.xml") if Path(path).is_dir() else [path]

    if not xml_files:
        print(f"No XML files found in {path}")
        sys.exit(0)

    all_issues = []
    for f in xml_files:
        all_issues.extend(check_file(f))

    # Group by severity
    high = [i for i in all_issues if i["severity"] == "HIGH"]
    medium = [i for i in all_issues if i["severity"] == "MEDIUM"]

    print(f"\n🔍 Accessibility Report")
    print(f"   Files checked : {len(xml_files)}")
    print(f"   HIGH issues   : {len(high)}")
    print(f"   MEDIUM issues : {len(medium)}")

    if high:
        print("\n🔴 HIGH — Missing Labels (screen reader users cannot identify these):")
        for i in high:
            print(f"   [{i['screen']}] {i['rule']} | {i['class']} | bounds={i['bounds']}")

    if medium:
        print("\n🟡 MEDIUM — Touch Target / Hint Issues:")
        for i in medium:
            print(f"   [{i['screen']}] {i['rule']} | {i['class']} | bounds={i['bounds']}")

    if not all_issues:
        print("\n✅ No accessibility issues found!")

    sys.exit(1 if high else 0)


if __name__ == "__main__":
    main()
