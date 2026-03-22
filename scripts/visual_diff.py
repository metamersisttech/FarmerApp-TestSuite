#!/usr/bin/env python3
"""
FarmerApp — Visual Regression Checker
=======================================
Compares current run screenshots against approved baselines.
Flags images with > THRESHOLD% pixel difference as regressions.

Usage:
  python3 scripts/visual_diff.py <current_screenshots_dir>

Baseline directory: docs/testing/baseline-screenshots/

To approve a new baseline (after manual review):
  cp docs/testing/reports/<timestamp>/screenshots/* docs/testing/baseline-screenshots/
"""

import sys
from pathlib import Path

THRESHOLD_PCT = 5.0   # flag if more than 5% of pixels changed

try:
    from PIL import Image, ImageChops, ImageFilter
except ImportError:
    print("⚠️  Pillow not installed. Run: pip3 install pillow")
    sys.exit(0)


def pixel_diff_pct(img1: Image.Image, img2: Image.Image) -> float:
    """Returns % of pixels that differ by more than 10 in any channel."""
    if img1.size != img2.size:
        return 100.0

    diff = ImageChops.difference(
        img1.convert("RGB"),
        img2.convert("RGB"),
    )
    pixels = list(diff.getdata())
    changed = sum(1 for p in pixels if max(p) > 10)
    return changed / len(pixels) * 100.0


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 visual_diff.py <current_screenshots_dir>")
        sys.exit(1)

    current_dir = Path(sys.argv[1])
    baseline_dir = Path(__file__).parent.parent / "docs" / "testing" / "baseline-screenshots"

    if not current_dir.exists():
        print(f"❌ Current screenshots dir not found: {current_dir}")
        sys.exit(1)

    current_files = sorted(current_dir.glob("*.png"))
    if not current_files:
        print("No screenshots found to compare.")
        sys.exit(0)

    regressions = []
    new_screens = []
    ok_count = 0

    print(f"🔍 Visual Diff: comparing {len(current_files)} screenshots against baseline")
    print(f"   Baseline: {baseline_dir}")
    print(f"   Current : {current_dir}")
    print()

    for current_file in current_files:
        base_file = baseline_dir / current_file.name

        if not base_file.exists():
            new_screens.append(current_file.name)
            print(f"  🆕 NEW (no baseline): {current_file.name}")
            continue

        try:
            img_base = Image.open(base_file)
            img_curr = Image.open(current_file)
            diff_pct = pixel_diff_pct(img_base, img_curr)

            if diff_pct > THRESHOLD_PCT:
                regressions.append({
                    "name": current_file.name,
                    "diff_pct": round(diff_pct, 2),
                })
                print(f"  ❌ REGRESSION {diff_pct:.1f}% diff: {current_file.name}")
            else:
                ok_count += 1
                print(f"  ✅ OK ({diff_pct:.1f}%): {current_file.name}")
        except Exception as e:
            print(f"  ⚠️  Could not compare {current_file.name}: {e}")

    print()
    print(f"Summary:")
    print(f"  Passed   : {ok_count}")
    print(f"  New      : {len(new_screens)}")
    print(f"  Regressions: {len(regressions)}")

    if regressions:
        print("\n❌ Regressions detected — review screenshots and update baseline if intentional:")
        for r in regressions:
            print(f"  {r['name']} — {r['diff_pct']}% changed")
        print(f"\nTo approve: cp {current_dir}/*.png {baseline_dir}/")
        sys.exit(1)
    else:
        print("\n✅ No visual regressions detected!")
        sys.exit(0)


if __name__ == "__main__":
    main()
