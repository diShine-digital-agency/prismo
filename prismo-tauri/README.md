# Prismo Tauri

**A professional desktop GUI for the Prismo AI Consulting Toolkit.**

Prismo Tauri transforms the [Prismo](https://github.com/diShine-digital-agency/prismo) CLI toolkit into a cross-platform desktop application built with [Tauri v2](https://tauri.app), React, and TypeScript. It provides a visual interface for running audits, viewing reports, exporting branded documents, and managing client profiles.

Built by [diShine Digital Agency](https://dishine.it).

---

## Features

### 🖥️ Desktop Application
- Native desktop app for Windows, macOS, and Linux
- Professional dark-theme UI with Prismo branding
- Lightweight binary (~3-10 MB + WebView2)
- USB-portable architecture

### 🔍 19 Audit Categories
| Category | Audits | New in Tauri |
|----------|--------|--------------|
| System Health | Windows, Linux, macOS diagnosis, Log analysis, Network diagnostics | — |
| Web & Performance | Website performance, Tech stack analysis, Accessibility | — |
| SEO | Technical SEO, On-page SEO, Competitive analysis | — |
| MarTech & Data | MarTech stack, Data quality | — |
| Security | Website security, System security | — |
| Email & DNS | SPF, DKIM, DMARC, MX records, DNS security | ✅ |
| Privacy | GDPR compliance, Cookie consent, Privacy policy | ✅ |
| Social | Open Graph, Twitter Cards, Schema.org structured data | ✅ |
| API | API security, CORS, Rate limiting, Auth | ✅ |

### 📤 Branded Report Export
Export audit reports in multiple formats — all with professional branding:

| Format | Branded | Printable | Method |
|--------|---------|-----------|--------|
| **PDF** | ✅ Cover page, logo, colors, footer | ✅ | Print dialog or md-to-pdf |
| **HTML** | ✅ Full CSS styling | ✅ | One-click export |
| **Markdown** | ✅ Header/footer branding | via viewer | One-click export |
| **Plain Text** | ASCII text | ✅ | One-click export |

### 👥 Client Manager
- Create and manage client profiles
- Store context (domain, industry, tech stack, competitors)
- Richer audit results with client-specific context

### ⚙️ Settings
- Language selection (English, Italian, French)
- API key management
- White-label mode (rebrand with your agency name)
- Theme configuration (dark mode)

---

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | Tauri v2 | Native desktop app with Rust backend |
| Frontend | React 19 + TypeScript | UI components |
| Styling | Tailwind CSS v4 | Utility-first CSS |
| Markdown | react-markdown | Report rendering |
| Build | Vite 7 | Fast bundling |
| Backend | Rust (Tauri) | File ops, system commands, process management |

---

## Getting Started

### Prerequisites
- [Node.js 22+](https://nodejs.org)
- [Rust](https://rustup.rs)
- Platform-specific dependencies:
  - **Linux**: `libwebkit2gtk-4.1-dev librsvg2-dev libgtk-3-dev libsoup-3.0-dev`
  - **macOS**: Xcode Command Line Tools
  - **Windows**: WebView2 (pre-installed on Windows 10/11)

### Development

```bash
# Navigate to the project
cd prismo-tauri

# Install dependencies
npm install

# Start development server
npm run tauri dev
```

### Build for Production

```bash
# Build optimized binary
npm run tauri build
```

The output binary will be in `src-tauri/target/release/`.

---

## Project Structure

```
prismo-tauri/
├── src/                        # Frontend (React + TypeScript)
│   ├── components/
│   │   ├── Sidebar.tsx         # Navigation sidebar
│   │   └── AuditCard.tsx       # Audit option cards
│   ├── pages/
│   │   ├── Dashboard.tsx       # Overview, quick-start
│   │   ├── AuditRunner.tsx     # Select & run audits
│   │   ├── Reports.tsx         # View past reports
│   │   ├── ReportViewer.tsx    # Render & export reports
│   │   ├── ClientManager.tsx   # Client profile management
│   │   ├── Settings.tsx        # App configuration
│   │   └── ExportCenter.tsx    # Export format info & tools
│   ├── App.tsx                 # Root component with routing
│   ├── main.tsx                # React entry point
│   └── index.css               # Tailwind CSS + brand styles
├── src-tauri/                  # Backend (Rust)
│   ├── src/
│   │   ├── lib.rs              # Tauri commands (audit, config, reports)
│   │   └── main.rs             # Entry point
│   ├── Cargo.toml              # Rust dependencies
│   ├── tauri.conf.json         # Tauri app configuration
│   └── capabilities/           # Security permissions
├── toolkit/
│   ├── prompts/                # All 19 audit prompt templates
│   │   ├── system/             # 5 system health prompts
│   │   ├── web/                # 3 web performance prompts
│   │   ├── seo/                # 3 SEO prompts
│   │   ├── martech/            # 2 MarTech prompts
│   │   ├── security/           # 2 security prompts
│   │   ├── email-dns/          # 1 email/DNS prompt (NEW)
│   │   ├── privacy/            # 1 GDPR/privacy prompt (NEW)
│   │   ├── social/             # 1 social media prompt (NEW)
│   │   └── api/                # 1 API security prompt (NEW)
│   └── export/                 # Report export templates
│       ├── report-style.css    # Branded CSS for PDF export
│       └── README.md           # Export documentation
├── assets/
│   └── branding/               # Brand assets & guidelines
│       ├── BRAND.md            # Brand guidelines
│       └── colors.json         # Color palette definition
├── docs/
│   └── examples/               # Sample outputs
│       ├── sample-client-profile.json
│       └── sample-report-website-performance.md
├── public/
│   └── prismo-icon.svg         # App icon
├── package.json
├── vite.config.ts
└── tsconfig.json
```

---

## Brand Colors

| Name | Hex | Usage |
|------|-----|-------|
| Prismo Purple | `#6C5CE7` | Primary brand color |
| Teal Accent | `#00CEC9` | Secondary highlights |
| Charcoal | `#2D3436` | Body text, dark backgrounds |
| Success Green | `#00B894` | Passed checks |
| Warning Amber | `#FDCB6E` | Medium severity |
| Danger Coral | `#E17055` | High severity |
| Critical Red | `#D63031` | Critical severity |

---

## Relationship to Prismo CLI

Prismo Tauri is a **separate project** that wraps the original [Prismo CLI toolkit](https://github.com/diShine-digital-agency/prismo) in a desktop GUI. It:

- Includes all 15 original audit prompts + 4 new categories
- Adds branded report export (PDF, HTML, Markdown, TXT)
- Provides a visual client profile manager
- Offers a settings panel with white-label support
- Does **not** modify the original Prismo repository

The CLI version remains the primary tool for USB-based on-site audits. Prismo Tauri is designed for consultants who prefer a GUI workflow or need branded report delivery.

---

## License

MIT License — see [LICENSE](../LICENSE) for details.

Copyright (c) 2026 [diShine Digital Agency](https://dishine.it)
