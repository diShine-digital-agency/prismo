# Prismo

**AI Consulting Toolkit: Portable, powerful, zero-installation.**

> Carry your AI-powered digital consulting toolkit on a USB drive. Run diagnostics, audits, and analysis on any machine — Windows, Linux, macOS — without installing anything.

Built by [diShine Digital Agency](https://dishine.it)

---

## What is Prismo?

Prismo is a portable USB toolkit that bundles an AI-powered CLI with pre-built diagnostic prompts for **digital consulting work**: website performance audits, SEO analysis, MarTech stack reviews, security scans, and traditional system diagnostics. The current version uses [Claude Code](https://docs.anthropic.com/en/docs/claude-code) as its AI backend.

Insert the USB. Launch a script. Get an AI-powered consulting report. Remove the USB — no traces left.

### Who is it for?

- **Digital consultants** visiting client sites
- **Marketing technologists** auditing analytics and tracking setups
- **SEO specialists** performing technical site audits
- **IT consultants** diagnosing systems without installing tools
- **Agency teams** needing a portable, standardized audit toolkit

---

## Features

### System Health
| # | Feature | Description |
|---|---------|-------------|
| 1 | System Diagnosis | Full workstation health check (CPU, RAM, disk, services, logs) |
| 2 | Log Analysis | Parse and diagnose any log file for errors and anomalies |
| 3 | Network Diagnostics | Interfaces, DNS, routing, ports, firewall, connectivity tests |

### Web & Performance
| # | Feature | Description |
|---|---------|-------------|
| 4 | Website Performance Audit | Lighthouse + Core Web Vitals (LCP, INP, CLS) |
| 5 | Tech Stack Analysis | Detect frameworks, CMS, hosting, CDN, third-party scripts |
| 6 | Accessibility Audit | WCAG 2.1 AA compliance check with pa11y |

### SEO
| # | Feature | Description |
|---|---------|-------------|
| 7 | Technical SEO Audit | robots.txt, sitemaps, canonicals, schema, hreflang, redirects |
| 8 | On-page SEO Analysis | Titles, metas, headings, content ratio, images, internal links |
| 9 | Competitive SEO Snapshot | Compare client vs competitors on visible SEO signals |

### MarTech & Data
| # | Feature | Description |
|---|---------|-------------|
| 10 | MarTech Stack Audit | GTM, GA4, pixels, CRM, email platforms, consent management |
| 11 | Data Quality Check | GA4 events, UTM consistency, conversion tracking, data layer |

### Security
| # | Feature | Description |
|---|---------|-------------|
| 12 | Website Security Scan | SSL/TLS, security headers, CMS vulnerabilities, cookie flags |
| 13 | System Security Audit | Users, permissions, firewall, SSH, updates, SUID/SGID |

### Utilities
| # | Feature | Description |
|---|---------|-------------|
| 14 | Interactive AI Session | Direct access to the AI engine for custom queries |
| 15 | Remote SSH Diagnostics | Connect and diagnose remote servers |
| 0 | Safe USB Eject | Gracefully unmount across all platforms |

---

## Quick Start

### 1. Prepare the USB (one-time setup)

On a Windows machine with internet access:

```powershell
# Insert USB drive (e.g., drive E:)
.\setup-usb.ps1 -UsbDrive E
```

This downloads Node.js, the AI engine, Lighthouse, and pa11y onto the USB drive (~900MB).

### 2. Use on any machine

**Windows:**
```
Double-click launch.bat
```

**macOS / Linux:**
```bash
bash /Volumes/USB/launch.sh
# or
bash /media/user/USB/launch.sh
```

### 3. Select an audit and go

Choose from 15 options. For web/SEO/MarTech audits, you'll be prompted for the target URL. Reports are saved to `toolkit/reports/`.

---

## Platform Support

| Platform | Diagnosis | Web Audit | Repair |
|----------|-----------|-----------|--------|
| Windows 10/11 | Full | Full | Guided |
| Windows Server 2016+ | Full | Full | Guided |
| macOS (Intel + Apple Silicon) | Full | Full | Guided |
| Linux (x64) | Full | Full | Guided |

---

## USB Drive Structure

```
USB_ROOT/
├── launch.sh              # Linux/macOS launcher
├── launch.bat             # Windows CMD launcher
├── launch.ps1             # Windows PowerShell launcher
├── setup-usb.ps1          # One-time USB preparation script
├── prismo.config.json     # Configuration (language, client, preferences)
├── prismo-eject.ps1       # Safe USB eject (Windows)
├── runtime/               # Portable Node.js + Git (downloaded by setup)
├── engine/                # AI engine + Lighthouse + pa11y
├── config/                # Credentials (stay on USB)
└── toolkit/
    ├── prompts/
    │   ├── system/        # Windows, Linux, macOS health checks
    │   ├── web/           # Performance, tech stack, accessibility
    │   ├── seo/           # Technical, on-page, competitive
    │   ├── martech/       # Stack audit, data quality
    │   └── security/      # Website security scan
    ├── scripts/           # Data collection scripts per platform
    ├── reports/           # Generated audit reports (Markdown)
    ├── clients/           # Client profile JSON files
    └── logs/              # Session logs
```

---

## Configuration

Edit `prismo.config.json` to set defaults:

```json
{
  "language": "auto",
  "client": {
    "name": "Acme Corp",
    "domain": "acme.com"
  },
  "preferences": {
    "auto_save_reports": true
  }
}
```

### Client Profiles

Store per-client context in `toolkit/clients/`:

```json
{
  "name": "Acme Corp",
  "domain": "acme.com",
  "stack": "WordPress + WooCommerce",
  "analytics": "GA4 + GTM",
  "previous_audits": ["2026-01-15", "2026-03-20"],
  "notes": "Migration to headless planned for Q3"
}
```

---

## Authentication

Prismo requires an active Claude subscription (Claude Pro, Max, or an API key from [console.anthropic.com](https://console.anthropic.com)). Authentication happens during setup and credentials are stored only on the USB drive.

- **Browser login**: Handled automatically during `setup-usb.ps1`
- **API key**: Set in `config/.claude/settings.json`
- **Credential security**: If you lose the USB drive, revoke your session immediately at [console.anthropic.com](https://console.anthropic.com)

---

## Security and Transparency

**What you should know:**

- Prismo is **not designed for regulated environments** (GDPR, HIPAA, PCI-DSS, ISO 27001)
- Diagnostic data transits through Anthropic's API — do not use on systems with classified or sensitive personal data
- Credentials are stored on the USB drive in plaintext — encrypt the drive (BitLocker, VeraCrypt, FileVault)
- The AI engine executes real commands — always review and confirm before approving destructive actions
- SHA256 checksums verify script integrity at launch — tampering is detected and flagged

**Best practices:**

- Encrypt your USB drive
- Use API keys with spending limits
- Rotate credentials periodically
- Review all proposed fixes before confirming
- Use on non-critical, non-regulated systems only

---

## Requirements

- **USB drive**: 2GB+ (exFAT or NTFS recommended)
- **Setup machine**: Windows with PowerShell 5.1+, internet connection
- **Target machine**: Windows 10+, macOS 10.15+, or Linux (x64)
- **Claude account**: Pro, Max, or API key ([anthropic.com](https://anthropic.com))

---

## Acknowledgments

Prismo is built upon the foundation of [Wolfix](https://github.com/ipalumbo73/wolfix) by **Ivan Palumbo**. The portable AI infrastructure — Node.js extraction, cross-platform launchers, USB eject handling — originates from his work. We are grateful for his contribution to the open-source community.

---

## License

MIT License — see [LICENSE](LICENSE) for details.

Copyright (c) 2026 [diShine Digital Agency](https://dishine.it)

---

## About diShine

**diShine Digital Agency** — Transform. Automate. Shine.

We help businesses navigate digital transformation through AI strategy, MarTech ecosystem design, data analytics, and automation.

- Web: [dishine.it](https://dishine.it)
- GitHub: [github.com/diShine-digital-agency](https://github.com/diShine-digital-agency)
- Location: Milan, Italy
