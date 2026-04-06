# Changelog

All notable changes to Prismo are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-04-06

### Added

- **Missing prompt files** — created `system/log-analysis.md`, `system/network-diagnosis.md`, and `security/system-security.md` to support all 15 menu options with dedicated prompt templates.
- **French language support** — added full French translation for the bash launcher menu and messages.
- **Dynamic version display** — all launchers now read the version number from the `VERSION` file instead of hardcoded strings.
- **Repository documentation** — added `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, and `CODE_OF_CONDUCT.md`.
- **Client industry field** — added `industry` field to `prismo.config.json` for richer client context in audits.
- **Directory placeholders** — added `.gitkeep` files to preserve required empty directories in version control.

### Fixed

- **Pre-language error messages** — error messages shown before language selection (Node.js not found, AI engine not found) are now in English instead of Italian only.
- **Eject script text** — removed bilingual text from `prismo-eject.ps1` fallback message.
- **French fallback** — French language option in `launch.sh` no longer silently falls back to English.

### Changed

- **Configuration** — removed marketing tagline from `prismo.config.json`, keeping only functional fields.
- **README** — restructured for clarity, removed promotional language, added badges and structured sections.
- **GUIDE** — reviewed for completeness and consistency.

## [1.0.0] — 2026-03-20

### Added

- Initial release of Prismo AI Consulting Toolkit.
- 15 diagnostic and audit options: system health (Windows/Linux/macOS), log analysis, network diagnostics, website performance, tech stack analysis, accessibility (WCAG 2.1), technical SEO, on-page SEO, competitive SEO, MarTech stack, data quality, website security, system security, interactive AI session, remote SSH diagnostics.
- Cross-platform launchers: `launch.bat` (Windows CMD), `launch.ps1` (Windows PowerShell), `launch.sh` (Linux/macOS).
- USB setup script (`setup-usb.ps1`) for one-time USB drive preparation.
- Safe USB eject across all platforms.
- Bilingual UI (Italian/English).
- SHA256 checksum verification for tamper detection.
- Session logging to `toolkit/logs/`.
- Client profile support via `toolkit/clients/`.
- 12 hardened diagnostic prompts for the AI engine.
- 5 data collection scripts (Windows, Linux, macOS, web, session logging).
- Portable Node.js runtime, AI engine, Lighthouse, and pa11y bundled on USB.
- Comprehensive user guide (`GUIDE.md`).

[1.1.0]: https://github.com/diShine-digital-agency/prismo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/diShine-digital-agency/prismo/releases/tag/v1.0.0
