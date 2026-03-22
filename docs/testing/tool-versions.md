# Tool Versions — FarmerApp Test Suite

Record verified working versions here. Update when upgrading.

| Tool | Required | Verified Working |
|------|----------|-----------------|
| Java | 17+ | OpenJDK 17.0.x |
| ADB | any | Android Debug Bridge 34+ |
| Maestro | 1.40.0 | 1.40.0 |
| Flutter | 3.x stable | 3.32.0 |
| Python | 3.9+ | 3.11.x |
| ffmpeg | any | 6.x |
| macOS (CI) | 12+ | macos-latest (GitHub Actions) |
| Android API | 33 | API 33 (Google APIs x86_64) |

## Python Packages

| Package | Version |
|---------|---------|
| pillow | 10.x |
| anthropic | 0.25.x |
| lxml | 5.x |
| jinja2 | 3.x |
| requests | 2.x |

## Notes
- Maestro is pinned to avoid breaking changes between minor releases
- Java 17 is the minimum — Maestro will not start with Java 11
- macOS is used for CI because Android emulator has hardware acceleration on macOS runners
