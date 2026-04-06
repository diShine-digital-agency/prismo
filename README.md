# Prismo

**A zero-footprint AI consulting toolkit for on-site audits.**

Digital consultants waste hours setting up environments on client machines—installing Node, Chrome, or CLI tools—only to scrub them clean a day later. Prismo eliminates the overhead. Plug in the USB, run your audit, and pull the drive. No installation, no residue, no "it works on my machine" excuses.

Prismo bundles a portable Node.js runtime with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and a library of hardened diagnostic prompts. It handles everything from Core Web Vitals and Technical SEO to MarTech data layer validation across Windows, macOS, and Linux.

Built by [diShine](https://dishine.it). For more details about Prismo, [read the detailled article on diShine Blog](https://dishine.it/blog/prismo-ai-consulting-toolkit-usb/).

---

## The philosophy: plug, audit, leave.

We built Prismo because "professionalism" shouldn't involve asking a client's IT department for admin rights just to run Lighthouse. 

- **Zero Residue:** nothing is written to the host’s permanent storage.
- **Unified Logic:** your SEO, Tech, and Security audits use the same AI-driven logic every time.
- **Offline-First Prep:** setup happens on your machine; the client machine only provides the internet gateway for the AI.
- **Client Continuity:** profiles are stored on the drive, allowing you to compare today's audit with the one from six months ago instantly.

---

## How 'Zero-Footprint' Works (Air-Gapped vs Offline)

### 🌐 Internet Requirements
**Prismo is Zero-Footprint, but NOT Air-Gapped.** 
While absolutely no software is installed on the client's hard drive, Prismo **requires an active internet connection** to query the Anthropic AI engine. The host machine acts strictly as a network gateway for the portable Node.js runtime to reach the Claude APIs.

---

## What's included

### System health
| # | Audit | What it covers |
|---|-------|----------------|
| 1 | System diagnosis | full workstation health check -- CPU, RAM, disk, services, logs |
| 2 | Log analysis | parses any log file for errors and anomalies |
| 3 | Network diagnostics | interfaces, DNS, routing, ports, firewall, connectivity |

### Web and performance
| # | Audit | What it covers |
|---|-------|----------------|
| 4 | Website performance | Lighthouse + Core Web Vitals (LCP, INP, CLS) |
| 5 | Tech stack analysis | detects frameworks, CMS, hosting, CDN, third-party scripts |
| 6 | Accessibility | WCAG 2.1 AA compliance via pa11y |

### SEO
| # | Audit | What it covers |
|---|-------|----------------|
| 7 | Technical SEO | robots.txt, sitemaps, canonicals, schema, hreflang, redirects |
| 8 | On-page SEO | titles, metas, headings, content ratio, images, internal links |
| 9 | Competitive snapshot | compares client vs competitors on visible SEO signals |

### MarTech and data
| # | Audit | What it covers |
|---|-------|----------------|
| 10 | MarTech stack | GTM, GA4, pixels, CRM, email platforms, consent management |
| 11 | Data quality | GA4 events, UTM consistency, conversion tracking, data layer |

### Security
| # | Audit | What it covers |
|---|-------|----------------|
| 12 | Website security | SSL/TLS, security headers, CMS vulnerabilities, cookie flags |
| 13 | System security | users, permissions, firewall, SSH, updates, SUID/SGID |

### Utilities
| # | Audit | What it covers |
|---|-------|----------------|
| 14 | Interactive AI session | direct access to the AI engine for custom queries |
| 15 | Remote SSH diagnostics | connect and diagnose remote servers |
| 0 | Safe USB eject | gracefully unmount across all platforms |

---

## Getting started

### 1. Prepare the USB (one-time, needs internet)

On a Windows machine with PowerShell:

```powershell
# Insert USB drive (e.g., drive E:)
.\setup-usb.ps1 -UsbDrive E
```

This downloads Node.js, the AI engine, Lighthouse, and pa11y onto the drive. It's about 900MB total.

### 2. Use it on any machine

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

### 3. Pick an audit

Choose from 15 options. For web/SEO/MarTech audits, you'll be asked for the target URL. Reports get saved to `toolkit/reports/`.

---

## 🛠️ First-Time Setup (Populating the Runtimes)

Prismo relies on portable binaries that are too large to host on GitHub. Before your first audit, you must prepare the USB drive:

1. **Format a USB Drive** to exFAT (for Windows/macOS compatibility).
2. **Clone/Copy this repository** to the root of the USB drive.
3. **Download Node.js Portable:**
   - Download the Node.js binaries for Windows, macOS, and Linux.
   - Extract them into `prismo/runtime/node-win-x64/`, `prismo/runtime/node-macos-arm64/`, etc.
4. **Install Claude Code:**
   - From your host machine, run `npm install -g @anthropic-ai/claude-code --prefix /path/to/usb/engine`
5. **Generate the Integrity File:**
   - For security, Prismo checks for tampering. Generate the hash file from the root of the USB:
   - `find . -type f -not -name "SHA256SUMS" -exec sha256sum {} + > SHA256SUMS`

---

## Platform support

| Platform | Diagnosis | Web audit | Repair |
|----------|-----------|-----------|--------|
| Windows 10/11 | full | full | guided |
| Windows Server 2016+ | full | full | guided |
| macOS (Intel + Apple Silicon) | full | full | guided |
| Linux (x64) | full | full | guided |

---

## What's on the USB

```
USB_ROOT/
├── launch.sh              # Linux/macOS launcher
├── launch.bat             # Windows CMD launcher
├── launch.ps1             # Windows PowerShell launcher
├── setup-usb.ps1          # one-time USB preparation script
├── prismo.config.json     # configuration (language, client, preferences)
├── prismo-eject.ps1       # safe USB eject (Windows)
├── runtime/               # portable Node.js + Git (downloaded by setup)
├── engine/                # AI engine + Lighthouse + pa11y
├── config/                # credentials (stay on the USB)
└── toolkit/
    ├── prompts/
    │   ├── system/        # Windows, Linux, macOS health checks
    │   ├── web/           # performance, tech stack, accessibility
    │   ├── seo/           # technical, on-page, competitive
    │   ├── martech/       # stack audit, data quality
    │   └── security/      # website security scan
    ├── scripts/           # data collection scripts per platform
    ├── reports/           # generated audit reports (Markdown)
    ├── clients/           # client profile JSON files
    └── logs/              # session logs
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

### Client profiles

You can store per-client context in `toolkit/clients/` so the AI has background on who you're auditing. This means repeat visits build on previous findings instead of starting from scratch.

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

Prismo needs an active Claude subscription (Pro, Max, or an API key from [console.anthropic.com](https://console.anthropic.com)). Authentication happens during setup and credentials are stored only on the USB drive itself.

- **Browser login**: handled automatically during `setup-usb.ps1`
- **API key**: set in `config/.claude/settings.json`
- **If you lose the USB**: revoke your session immediately at [console.anthropic.com](https://console.anthropic.com)

---

## Security

Prismo is a consulting convenience tool, not an enterprise security product. Here's what you should know:

- It's **not designed for regulated environments** (GDPR processing, HIPAA, PCI-DSS, ISO 27001 scoping)
- Diagnostic data transits through Anthropic's API - don't use it on systems with classified or sensitive personal data
- Credentials sit on the USB drive in plaintext, so encrypt the drive (BitLocker, VeraCrypt, or FileVault)
- The AI engine can execute real commands - always review and confirm before approving anything destructive
- SHA256 checksums verify script integrity at launch, so tampering gets detected and flagged

**Practical advice:**

- Encrypt your USB drive
- Use API keys with spending limits
- Rotate credentials periodically
- Review every proposed fix before confirming
- Stick to non-critical, non-regulated systems

---

## Requirements

- **USB drive**: 2GB+ (exFAT or NTFS recommended)
- **Setup machine**: Windows with PowerShell 5.1+, internet connection
- **Target machine**: Windows 10+, macOS 10.15+, or Linux (x64)
- **Claude account**: Pro, Max, or API key ([anthropic.com](https://anthropic.com))

---

## Acknowledgments

Prismo builds on the foundation of [Wolfix](https://github.com/ipalumbo73/wolfix) by **Ivan Palumbo**. The portable AI infrastructure - Node.js extraction, cross-platform launchers, USB eject handling - originates from his work. We're grateful for his contribution to the open-source community.

---

## License

MIT License - see [LICENSE](LICENSE) for details.

Copyright (c) 2026 [diShine](https://dishine.it)

---

## About diShine

[diShine](https://dishine.it) is a small creative tech agency based in Milan. We build tools for digital consultants, help businesses with AI strategy and MarTech architecture, and occasionally open-source the things we wish existed.

- Web: [dishine.it](https://dishine.it)
- GitHub: [github.com/diShine-digital-agency](https://github.com/diShine-digital-agency)
