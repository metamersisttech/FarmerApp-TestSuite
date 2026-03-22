#!/usr/bin/env python3
"""
FarmerApp — Unified Test Report Generator
==========================================
Aggregates JUnit XML results from three test sources:
  1. Maestro UI tests       (results.xml)
  2. Flutter unit/widget    (flutter-test-results.xml)
  3. Django backend tests   (backend-coverage.xml / backend-results.xml)

Produces:
  - unified_report.html  : Bootstrap HTML dashboard
  - unified_summary.json : Machine-readable totals for CI

Usage:
    python3 scripts/generate_unified_report.py [--dir <report_dir>]

Options:
    --dir          Working directory (default: current directory)
    --maestro      Path to Maestro JUnit XML      (default: results.xml)
    --flutter      Path to Flutter JUnit XML      (default: flutter-results.xml)
    --backend      Path to Django JUnit XML       (default: backend-results.xml)
    --coverage     Path to Django coverage XML    (default: coverage.xml)
    --screenshots  Screenshots directory          (default: screenshots/)
    --output       Output HTML file               (default: unified_report.html)
    --summary      Output JSON file               (default: unified_summary.json)
"""

import sys
import json
import argparse
import base64
import xml.etree.ElementTree as ET
from pathlib import Path
from datetime import datetime, timezone

# ── HTML Template ─────────────────────────────────────────────────────────────
HTML_TEMPLATE = r"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>FarmerApp Unified Test Report — {timestamp}</title>
  <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
    integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
    crossorigin="anonymous" />
  <style>
    body {{ font-family: 'Segoe UI', sans-serif; background: #f0f2f5; }}
    .suite-header {{ background: linear-gradient(135deg, #1a3a2a 0%, #2d5a3d 100%);
                     color: white; border-radius: 12px 12px 0 0; }}
    .stat-card {{ border-radius: 12px; transition: transform .15s; }}
    .stat-card:hover {{ transform: translateY(-2px); }}
    .progress-bar-animated {{ animation: progress-bar-stripes 1s linear infinite; }}
    .test-row-fail {{ background: #fff5f5; }}
    .test-row-skip {{ background: #fffbf0; }}
    .screenshot-img {{ border-radius: 8px; border: 1px solid #dee2e6;
                       max-width: 160px; cursor: zoom-in; transition: transform .2s; }}
    .screenshot-img:hover {{ transform: scale(1.05); }}
    .coverage-bar {{ height: 22px; border-radius: 4px; }}
    .suite-badge {{ font-size: 0.65rem; text-transform: uppercase; letter-spacing: .05em; }}
    .error-pre {{ font-size: 0.73rem; max-height: 200px; overflow-y: auto;
                  background: #1e1e1e; color: #d4d4d4; border-radius: 6px; }}
    .nav-tabs .nav-link {{ color: #495057; }}
    .nav-tabs .nav-link.active {{ font-weight: 600; }}
  </style>
</head>
<body class="p-4">

<!-- Header -->
<div class="d-flex align-items-center mb-4 gap-3 flex-wrap">
  <h1 class="mb-0">&#x1f33e; FarmerApp &mdash; Unified Test Report</h1>
  <span class="badge bg-secondary fs-6">{timestamp}</span>
  <span class="badge {overall_badge} fs-6">{overall_label}</span>
</div>

<!-- Top-level summary cards -->
<div class="row g-3 mb-4">
  <div class="col-6 col-md-3">
    <div class="card stat-card text-bg-{total_class} text-center p-3 h-100">
      <div class="display-5 fw-bold">{total_tests}</div>
      <div class="small">Total Tests</div>
    </div>
  </div>
  <div class="col-6 col-md-3">
    <div class="card stat-card text-bg-success text-center p-3 h-100">
      <div class="display-5 fw-bold">{total_passed}</div>
      <div class="small">Passed</div>
    </div>
  </div>
  <div class="col-6 col-md-3">
    <div class="card stat-card text-bg-{fail_class} text-center p-3 h-100">
      <div class="display-5 fw-bold">{total_failed}</div>
      <div class="small">Failed</div>
    </div>
  </div>
  <div class="col-6 col-md-3">
    <div class="card stat-card text-bg-warning text-center p-3 h-100">
      <div class="display-5 fw-bold">{total_skipped}</div>
      <div class="small">Skipped</div>
    </div>
  </div>
</div>

<!-- Per-suite breakdown -->
<div class="card mb-4 shadow-sm">
  <div class="suite-header p-3">
    <h5 class="mb-0">Per-Suite Summary</h5>
  </div>
  <div class="table-responsive">
    <table class="table table-hover mb-0">
      <thead class="table-light">
        <tr>
          <th>Suite</th>
          <th class="text-center">Total</th>
          <th class="text-center text-success">Passed</th>
          <th class="text-center text-danger">Failed</th>
          <th class="text-center text-warning">Skipped</th>
          <th>Pass Rate</th>
          <th class="text-center">Status</th>
        </tr>
      </thead>
      <tbody>
        {suite_rows}
      </tbody>
    </table>
  </div>
</div>

<!-- Tabs for each suite's details -->
<ul class="nav nav-tabs mb-3" id="suiteTabs" role="tablist">
{tab_headers}
</ul>
<div class="tab-content" id="suiteTabContent">
{tab_panes}
</div>

{coverage_section}

<footer class="mt-5 text-center text-muted small">
  Generated by FarmerApp CI &mdash; {timestamp}
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
  integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL"
  crossorigin="anonymous"></script>
<script>
// Click to expand screenshot
document.querySelectorAll('.screenshot-img').forEach(img => {{
  img.addEventListener('click', () => {{
    const m = new bootstrap.Modal(document.getElementById('imgModal'));
    document.getElementById('modalImg').src = img.src;
    m.show();
  }});
}});
</script>

<!-- Image modal -->
<div class="modal fade" id="imgModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-body p-1 text-center">
        <img id="modalImg" class="img-fluid rounded" src="" alt="screenshot" />
      </div>
    </div>
  </div>
</div>
</body>
</html>
"""

SUITE_ROW_TPL = """
<tr>
  <td><span class="badge {color} suite-badge me-1">{label}</span>{name}</td>
  <td class="text-center">{total}</td>
  <td class="text-center text-success fw-bold">{passed}</td>
  <td class="text-center {fail_color} fw-bold">{failed}</td>
  <td class="text-center text-warning">{skipped}</td>
  <td style="min-width:120px">
    <div class="progress coverage-bar">
      <div class="progress-bar bg-{bar_color}" style="width:{pct:.0f}%">{pct:.0f}%</div>
    </div>
  </td>
  <td class="text-center"><span class="badge bg-{status_color}">{status}</span></td>
</tr>
"""

TAB_HEADER_TPL = """
<li class="nav-item" role="presentation">
  <button class="nav-link {active}" id="tab-{slug}-tab"
    data-bs-toggle="tab" data-bs-target="#tab-{slug}"
    type="button" role="tab">{icon} {name}
    {badge}
  </button>
</li>
"""

TAB_PANE_TPL = """
<div class="tab-pane fade {show_active}" id="tab-{slug}" role="tabpanel">
  <div class="card shadow-sm mb-3">
    <div class="card-body">
{pane_content}
    </div>
  </div>
</div>
"""

COVERAGE_SECTION_TPL = """
<div class="card mb-4 shadow-sm">
  <div class="suite-header p-3">
    <h5 class="mb-0">&#x1f4ca; Backend Coverage</h5>
  </div>
  <div class="card-body">
    <div class="d-flex align-items-center gap-3 mb-3">
      <div class="display-6 fw-bold text-{cov_color}">{line_rate:.1f}%</div>
      <div>
        <div class="text-muted small">Line Coverage</div>
        <div class="progress" style="width:220px;height:18px">
          <div class="progress-bar bg-{cov_color}" style="width:{line_rate:.0f}%"></div>
        </div>
      </div>
      <div class="ms-4">
        <div class="text-muted small">Branch Coverage</div>
        <strong>{branch_rate:.1f}%</strong>
      </div>
    </div>
    <table class="table table-sm table-hover">
      <thead class="table-light">
        <tr>
          <th>File</th>
          <th class="text-end">Lines Valid</th>
          <th class="text-end">Lines Hit</th>
          <th class="text-end">Coverage</th>
        </tr>
      </thead>
      <tbody>
{cov_rows}
      </tbody>
    </table>
  </div>
</div>
"""


# ── XML Parsers ────────────────────────────────────────────────────────────────

def parse_junit(xml_path: Path) -> dict:
    """Return a dict with keys: total, passed, failed, skipped, duration, cases."""
    if not xml_path.exists():
        return {'total': 0, 'passed': 0, 'failed': 0, 'skipped': 0,
                'duration': 0.0, 'cases': [], 'source': str(xml_path)}

    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except ET.ParseError:
        return {'total': 0, 'passed': 0, 'failed': 0, 'skipped': 0,
                'duration': 0.0, 'cases': [], 'source': str(xml_path)}

    # Support both <testsuites> and <testsuite> at root
    if root.tag == 'testsuites':
        suites = list(root)
    elif root.tag == 'testsuite':
        suites = [root]
    else:
        suites = list(root.iter('testsuite'))

    total = failed = skipped = 0
    duration = 0.0
    cases = []

    for suite in suites:
        for tc in suite.iter('testcase'):
            total += 1
            t_dur = float(tc.get('time', 0) or 0)
            duration += t_dur

            failure = tc.find('failure')
            error = tc.find('error')
            skip = tc.find('skipped')

            if skip is not None:
                skipped += 1
                status = 'skip'
            elif failure is not None or error is not None:
                failed += 1
                status = 'fail'
                msg = (failure if failure is not None else error)
                cases.append({
                    'classname': tc.get('classname', ''),
                    'name': tc.get('name', ''),
                    'status': status,
                    'duration': t_dur,
                    'message': (msg.get('message') or msg.text or '')[:500],
                })
                continue
            else:
                status = 'pass'

            cases.append({
                'classname': tc.get('classname', ''),
                'name': tc.get('name', ''),
                'status': status,
                'duration': t_dur,
                'message': '',
            })

    passed = total - failed - skipped
    return {
        'total': total, 'passed': passed, 'failed': failed,
        'skipped': skipped, 'duration': duration, 'cases': cases,
        'source': str(xml_path),
    }


def parse_coverage_xml(xml_path: Path) -> dict:
    """Parse a Cobertura-format coverage.xml."""
    if not xml_path.exists():
        return {'line_rate': 0.0, 'branch_rate': 0.0, 'packages': []}
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
    except ET.ParseError:
        return {'line_rate': 0.0, 'branch_rate': 0.0, 'packages': []}

    line_rate = float(root.get('line-rate', 0) or 0) * 100
    branch_rate = float(root.get('branch-rate', 0) or 0) * 100

    packages = []
    for cls in root.iter('class'):
        filename = cls.get('filename', '')
        # Skip migrations and test files
        if '/migrations/' in filename or 'test' in filename.lower():
            continue
        valid = int(cls.get('complexity', 0) or 0)
        # Count actual line elements
        lines_el = list(cls.iter('line'))
        lines_valid = len(lines_el)
        lines_hit = sum(1 for l in lines_el if int(l.get('hits', 0) or 0) > 0)
        lr = (lines_hit / lines_valid * 100) if lines_valid else 0
        packages.append({
            'filename': filename,
            'lines_valid': lines_valid,
            'lines_hit': lines_hit,
            'line_rate': lr,
        })

    # Sort by line_rate ascending (worst first)
    packages.sort(key=lambda x: x['line_rate'])
    return {'line_rate': line_rate, 'branch_rate': branch_rate, 'packages': packages}


# ── HTML Builders ──────────────────────────────────────────────────────────────

def _pct(passed, total):
    return (passed / total * 100) if total else 0.0


def _bar_color(pct):
    if pct >= 90: return 'success'
    if pct >= 70: return 'info'
    if pct >= 50: return 'warning'
    return 'danger'


def build_suite_row(label, color, name, data):
    pct = _pct(data['passed'], data['total'])
    failed_color = 'text-danger' if data['failed'] > 0 else 'text-muted'
    status = 'PASS' if data['failed'] == 0 else 'FAIL'
    status_color = 'success' if data['failed'] == 0 else 'danger'
    return SUITE_ROW_TPL.format(
        label=label, color=color, name=name,
        total=data['total'], passed=data['passed'],
        failed=data['failed'], skipped=data['skipped'],
        fail_color=failed_color, pct=pct,
        bar_color=_bar_color(pct),
        status=status, status_color=status_color,
    )


def build_test_table(cases):
    if not cases:
        return '<p class="text-muted">No test cases found.</p>'

    rows = []
    for c in cases:
        row_class = ''
        if c['status'] == 'fail': row_class = 'test-row-fail'
        elif c['status'] == 'skip': row_class = 'test-row-skip'

        icon = {'pass': '✅', 'fail': '❌', 'skip': '⏭️'}.get(c['status'], '❓')
        error_html = ''
        if c['message']:
            error_html = f'<pre class="error-pre p-2 mt-1 mb-0">{c["message"]}</pre>'

        rows.append(f"""
<tr class="{row_class}">
  <td>{icon}</td>
  <td><small class="text-muted">{c['classname']}</small><br><strong>{c['name']}</strong>
  {error_html}</td>
  <td class="text-end text-muted small">{c['duration']:.2f}s</td>
</tr>""")

    return f"""
<table class="table table-sm table-hover">
  <thead class="table-light">
    <tr><th style="width:30px"></th><th>Test</th><th class="text-end">Time</th></tr>
  </thead>
  <tbody>{''.join(rows)}</tbody>
</table>"""


def build_screenshots_html(screenshots_dir: Path, limit=12):
    if not screenshots_dir.exists():
        return ''
    imgs = sorted(screenshots_dir.glob('*.png'))[:limit]
    if not imgs:
        return ''

    cards = []
    for img in imgs:
        data = base64.b64encode(img.read_bytes()).decode()
        cards.append(f"""
<div class="col-6 col-md-3 col-lg-2">
  <img src="data:image/png;base64,{data}"
       class="screenshot-img w-100 mb-1" alt="{img.stem}" />
  <div class="small text-muted text-truncate">{img.stem}</div>
</div>""")

    return f"""
<h6 class="mt-3">Screenshots ({len(imgs)} shown)</h6>
<div class="row g-2">{''.join(cards)}</div>"""


def build_coverage_section(cov: dict):
    if not cov['packages'] and cov['line_rate'] == 0.0:
        return ''

    cov_color = _bar_color(cov['line_rate'])
    rows = []
    for p in cov['packages'][:30]:
        bar_color = _bar_color(p['line_rate'])
        rows.append(f"""
<tr>
  <td><code>{p['filename']}</code></td>
  <td class="text-end">{p['lines_valid']}</td>
  <td class="text-end">{p['lines_hit']}</td>
  <td class="text-end">
    <div class="d-flex align-items-center gap-2 justify-content-end">
      <div class="progress" style="width:80px;height:14px">
        <div class="progress-bar bg-{bar_color}" style="width:{p['line_rate']:.0f}%"></div>
      </div>
      <span class="text-{bar_color} fw-bold small">{p['line_rate']:.0f}%</span>
    </div>
  </td>
</tr>""")

    return COVERAGE_SECTION_TPL.format(
        cov_color=cov_color,
        line_rate=cov['line_rate'],
        branch_rate=cov['branch_rate'],
        cov_rows=''.join(rows),
    )


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description='FarmerApp Unified Test Report')
    parser.add_argument('--dir', default='.', help='Working directory')
    parser.add_argument('--maestro', default='results.xml')
    parser.add_argument('--flutter', default='flutter-results.xml')
    parser.add_argument('--backend', default='backend-results.xml')
    parser.add_argument('--coverage', default='coverage.xml')
    parser.add_argument('--screenshots', default='screenshots')
    parser.add_argument('--output', default='unified_report.html')
    parser.add_argument('--summary', default='unified_summary.json')
    args = parser.parse_args()

    base = Path(args.dir)
    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')

    # Parse all three suites
    maestro_data = parse_junit(base / args.maestro)
    flutter_data = parse_junit(base / args.flutter)
    backend_data = parse_junit(base / args.backend)
    coverage = parse_coverage_xml(base / args.coverage)

    suites = [
        ('UI',       'bg-purple',   'bg-primary',    'Maestro UI Tests',     maestro_data),
        ('Flutter',  'bg-info',     'bg-info',        'Flutter Unit/Widget',  flutter_data),
        ('Backend',  'bg-success',  'bg-success',     'Django Backend Tests', backend_data),
    ]

    # Totals
    total   = sum(s[4]['total']   for s in suites)
    passed  = sum(s[4]['passed']  for s in suites)
    failed  = sum(s[4]['failed']  for s in suites)
    skipped = sum(s[4]['skipped'] for s in suites)

    overall_ok = failed == 0
    overall_label  = 'ALL PASS' if overall_ok else f'{failed} FAILED'
    overall_badge  = 'bg-success' if overall_ok else 'bg-danger'
    total_class    = 'primary'
    fail_class     = 'danger' if failed > 0 else 'secondary'

    # Per-suite table rows
    suite_rows_html = ''.join(
        build_suite_row(label, color, name, data)
        for label, color, _, name, data in suites
    )

    # Tab headers + panes
    tab_headers_html = []
    tab_panes_html   = []
    for i, (label, badge_color, _, name, data) in enumerate(suites):
        slug   = label.lower()
        active = 'active' if i == 0 else ''
        show   = 'show active' if i == 0 else ''
        icon   = {'UI': '📱', 'Flutter': '🐦', 'Backend': '🔧'}.get(label, '🔹')
        fail_badge = (
            f'<span class="badge bg-danger ms-1">{data["failed"]}</span>'
            if data['failed'] > 0 else ''
        )

        tab_headers_html.append(TAB_HEADER_TPL.format(
            active=active, slug=slug, icon=icon, name=name, badge=fail_badge
        ))

        # Build pane content
        test_table = build_test_table(data['cases'])
        screenshots_html = ''
        if label == 'UI':
            screenshots_html = build_screenshots_html(base / args.screenshots)

        pane_content = f"""
      <div class="d-flex gap-4 mb-3 flex-wrap">
        <div class="text-center"><div class="h3 mb-0">{data['total']}</div>
          <small class="text-muted">Total</small></div>
        <div class="text-center"><div class="h3 mb-0 text-success">{data['passed']}</div>
          <small class="text-muted">Passed</small></div>
        <div class="text-center"><div class="h3 mb-0 {'text-danger' if data['failed'] else 'text-muted'}">{data['failed']}</div>
          <small class="text-muted">Failed</small></div>
        <div class="text-center"><div class="h3 mb-0 text-warning">{data['skipped']}</div>
          <small class="text-muted">Skipped</small></div>
        <div class="text-center"><div class="h3 mb-0 text-secondary">{data['duration']:.1f}s</div>
          <small class="text-muted">Duration</small></div>
      </div>
      {screenshots_html}
      {test_table}"""

        tab_panes_html.append(TAB_PANE_TPL.format(
            slug=slug, show_active=show, pane_content=pane_content
        ))

    coverage_section = build_coverage_section(coverage)

    html = HTML_TEMPLATE.format(
        timestamp=timestamp,
        overall_label=overall_label,
        overall_badge=overall_badge,
        total_class=total_class,
        total_tests=total,
        total_passed=passed,
        total_failed=failed,
        total_skipped=skipped,
        fail_class=fail_class,
        suite_rows=suite_rows_html,
        tab_headers=''.join(tab_headers_html),
        tab_panes=''.join(tab_panes_html),
        coverage_section=coverage_section,
    )

    out_html = base / args.output
    out_html.write_text(html, encoding='utf-8')
    print(f'[unified-report] HTML written: {out_html}')

    summary = {
        'timestamp': timestamp,
        'result': 'PASS' if overall_ok else 'FAIL',
        'total': total,
        'passed': passed,
        'failed': failed,
        'skipped': skipped,
        'suites': {
            'maestro': {
                'total': maestro_data['total'],
                'passed': maestro_data['passed'],
                'failed': maestro_data['failed'],
            },
            'flutter': {
                'total': flutter_data['total'],
                'passed': flutter_data['passed'],
                'failed': flutter_data['failed'],
            },
            'backend': {
                'total': backend_data['total'],
                'passed': backend_data['passed'],
                'failed': backend_data['failed'],
            },
        },
        'coverage': {
            'line_rate': round(coverage['line_rate'], 1),
            'branch_rate': round(coverage['branch_rate'], 1),
        },
    }

    out_json = base / args.summary
    out_json.write_text(json.dumps(summary, indent=2), encoding='utf-8')
    print(f'[unified-report] Summary written: {out_json}')
    print(f'[unified-report] Result: {summary["result"]} '
          f'({passed}/{total} passed, {failed} failed)')

    return 1 if not overall_ok else 0


if __name__ == '__main__':
    sys.exit(main())
