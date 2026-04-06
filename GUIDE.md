# Prismo: Complete User Guide

**Everything you need to know to set up, use, and get the most out of Prismo.**

This guide is written for anyone — you don't need to be technical to follow it.

---

## Table of Contents

1. [What is Prismo?](#1-what-is-prismo)
2. [What You Need Before Starting](#2-what-you-need-before-starting)
3. [Setting Up the USB Drive (One-Time)](#3-setting-up-the-usb-drive-one-time)
4. [Launching Prismo](#4-launching-prismo)
5. [Understanding the Menu](#5-understanding-the-menu)
6. [Running Your First Audit](#6-running-your-first-audit)
7. [All 15 Features Explained](#7-all-15-features-explained)
8. [Working with Reports](#8-working-with-reports)
9. [Client Profiles](#9-client-profiles)
10. [Configuration](#10-configuration)
11. [Removing the USB Safely](#11-removing-the-usb-safely)
12. [Troubleshooting](#12-troubleshooting)
13. [Security & Privacy](#13-security--privacy)
14. [FAQ](#14-faq)

---

## 1. What is Prismo?

Prismo is a portable toolkit on a USB drive. You plug it into any computer, launch it, and it gives you access to 15 different diagnostic and audit tools — for websites, SEO, marketing technology, security, and system health.

**Think of it as a Swiss Army knife for digital consultants.**

It works on Windows, macOS, and Linux. You don't install anything on the computer — everything runs from the USB drive. When you're done, you remove the drive and leave no traces behind.

### What can it do?

| Category | Examples |
|----------|----------|
| **Website audits** | Check how fast a site loads, what tech stack it uses, if it's accessible to people with disabilities |
| **SEO analysis** | Find technical SEO issues, analyze page content, compare against competitors |
| **Marketing tech** | Detect Google Analytics, Tag Manager, tracking pixels, consent management |
| **Security scans** | Check SSL certificates, security headers, cookie flags, system vulnerabilities |
| **System health** | Diagnose hardware issues, analyze logs, check network configuration |

---

## 2. What You Need Before Starting

### For the one-time setup (preparing the USB)

- A **Windows computer** with internet access
- A **USB drive** with at least **2 GB** of free space (4 GB recommended)
  - Format: **exFAT** (works on all operating systems) or NTFS (Windows-only)
- A **Claude account** — one of these:
  - **Claude Pro** subscription ($20/month at [claude.ai](https://claude.ai))
  - **Claude Max** subscription ($100/month)
  - **API key** from [console.anthropic.com](https://console.anthropic.com) (pay-per-use)

> **Which Claude plan should I get?**
> If you're just starting out, Claude Pro ($20/month) is fine. It gives you enough usage for several audits per day. If you run audits heavily (10+ per day), consider Max or an API key.

### For using Prismo on a client's machine

- The prepared USB drive (from the setup step above)
- A computer running **Windows 10/11**, **macOS 10.15+**, or **Linux (x64)**
- **Internet connection** (Prismo needs to reach the AI service online)

---

## 3. Setting Up the USB Drive (One-Time)

You only need to do this **once**. After setup, the USB works on any computer.

### Step-by-step

1. **Insert your USB drive** into a Windows computer. Note the drive letter (e.g., `E:`)

2. **Download Prismo** from GitHub:
   - Go to [github.com/diShine-digital-agency/prismo](https://github.com/diShine-digital-agency/prismo)
   - Click the green **"Code"** button → **"Download ZIP"**
   - Extract the ZIP contents to the **root** of your USB drive

   Your USB should now look like this:
   ```
   E:\
   ├── launch.sh
   ├── launch.bat
   ├── launch.ps1
   ├── setup-usb.ps1
   ├── prismo.config.json
   ├── toolkit\
   │   ├── prompts\
   │   ├── scripts\
   │   ├── reports\
   │   └── ...
   └── ...
   ```

3. **Open PowerShell as Administrator**:
   - Press `Windows key`, type `PowerShell`
   - Right-click → **"Run as Administrator"**

4. **Run the setup script**:
   ```powershell
   E:\setup-usb.ps1 -UsbDrive E
   ```
   Replace `E` with your actual USB drive letter.

5. **Wait for the download to complete** (~5-10 minutes depending on your internet speed). The script will download:
   - Node.js runtime (~50 MB)
   - The AI engine (~200 MB)
   - Lighthouse and pa11y for web audits (~300 MB)

6. **Log into your Claude account** when prompted. This saves your authentication on the USB drive.

7. **Done!** You'll see a confirmation message. The USB is now ready to use on any machine.

### If the script won't run (execution policy error)

Windows may block PowerShell scripts by default. Run this first:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

Then retry the setup command.

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

## 4. Launching Prismo

### On Windows

**Option A — Double-click (easiest):**
- Open the USB drive in File Explorer
- Double-click **`launch.bat`**

**Option B — PowerShell:**
- Open PowerShell
- Navigate to the USB: `cd E:\` (replace `E` with your drive letter)
- Run: `.\launch.ps1`

### On macOS

1. Open **Terminal** (search for "Terminal" in Spotlight, or find it in Applications → Utilities)
2. Run:
   ```bash
   bash /Volumes/USB_NAME/launch.sh
   ```
   Replace `USB_NAME` with the name of your USB drive. You can find it by running `ls /Volumes/`.

### On Linux

1. Open a terminal
2. Run:
   ```bash
   bash /media/$USER/USB_NAME/launch.sh
   ```
   Replace `USB_NAME` with the name of your USB drive.

### What happens when you launch

1. Prismo checks that all files are intact (SHA256 verification)
2. It sets up the Node.js runtime in a temporary folder
3. It configures the AI engine
4. It detects your operating system and hardware
5. It asks you to choose a language (Italian, English, or French)
6. It shows the main menu

You should see something like this:

```
  ================================================
   ____  ____  ___ ____  __  __  ___
  |  _ \|  _ \|_ _/ ___||  \/  |/ _ \
  | |_) | |_) || |\___ \| |\/| | | | |
  |  __/|  _ < | | ___) | |  | | |_| |
  |_|   |_| \_\___|____/|_|  |_|\___/

    >_ AI Consulting Toolkit
       by diShine Digital Agency

    v1.0.0
    Portable — no installation required
  ================================================

  System: macOS 15.2
  Kernel: 24.2.0
  RAM:    16 GB
  Host:   MacBook-Pro.local

  [I] Italiano  [E] English  [F] Francais

  Language / Lingua:
```

---

## 5. Understanding the Menu

After choosing your language, the main menu appears:

```
  ┌─────────────────────────────────────────────┐
  │  ── System Health ──                        │
  │   [1]  System diagnosis                     │
  │   [2]  Log analysis                         │
  │   [3]  Network diagnostics                  │
  │  ── Web & Performance ──                    │
  │   [4]  Website performance audit            │
  │   [5]  Tech stack analysis                  │
  │   [6]  Accessibility audit (WCAG 2.1)       │
  │  ── SEO ──                                  │
  │   [7]  Technical SEO audit                  │
  │   [8]  On-page SEO analysis                 │
  │   [9]  Competitive SEO snapshot             │
  │  ── MarTech & Data ──                       │
  │  [10]  MarTech stack audit                  │
  │  [11]  Data quality check                   │
  │  ── Security ──                             │
  │  [12]  Website security scan                │
  │  [13]  System security audit                │
  │  ── Utilities ──                            │
  │  [14]  Interactive AI session               │
  │  [15]  Remote SSH diagnostics               │
  │                                             │
  │   [0]  Safe eject USB                       │
  │   [Q]  Quit                                 │
  └─────────────────────────────────────────────┘
```

**How to use it**: Type the number of the option you want and press Enter. For most options, you'll be asked for a URL or a file path, then the audit begins automatically.

After each audit, you'll return to the menu. You can run as many audits as you want in a single session.

---

## 6. Running Your First Audit

Let's walk through a complete example — auditing a website's SEO.

### Example: Technical SEO Audit

1. Launch Prismo (see [Section 4](#4-launching-prismo))
2. Choose your language
3. At the menu, type **`7`** and press Enter
4. You'll see: `Website URL:`
5. Type the website address, e.g., `example.com` and press Enter
6. Prismo will now:
   - Fetch the website
   - Analyze robots.txt, sitemap, canonical tags, structured data, etc.
   - Check mobile-friendliness, SSL, redirects, URL structure
   - Generate a full report with severity levels and fix instructions
7. The report appears directly in your terminal
8. A copy is automatically saved to `toolkit/reports/` on your USB drive

### Tips for your first run

- **You don't need to type `https://`** — just the domain name works (e.g., `stripe.com`)
- **The first audit takes a bit longer** — the AI engine needs to initialize
- **Read the full report** — it includes severity levels (CRITICAL, HIGH, MEDIUM, LOW) and exact fix instructions
- **Don't worry about the technical commands** running in the terminal — the AI handles everything automatically

---

## 7. All 15 Features Explained

### System Health (Options 1-3)

These diagnose the **computer you're running Prismo on** — useful for IT consulting.

#### [1] System Diagnosis
**What it does:** Runs a complete health check of the current machine.
**What it checks:** CPU usage, RAM, disk space, running services, error logs, Windows updates, antivirus status, scheduled tasks.
**When to use it:** First thing when diagnosing a client's workstation or server.
**Input needed:** None — it automatically scans the local machine.

#### [2] Log Analysis
**What it does:** Analyzes a log file you specify and identifies errors, warnings, and anomalies.
**When to use it:** When a client reports "the server crashed" or "the app has errors" — feed it the log file.
**Input needed:** The full path to a log file (e.g., `/var/log/syslog` or `C:\Windows\System32\LogFiles\...`).

#### [3] Network Diagnostics
**What it does:** Checks network configuration — interfaces, DNS, routing, open ports, firewall, connectivity.
**When to use it:** When a client has "internet problems" or "the app can't connect."
**Input needed:** None — it scans the local machine's network configuration.

---

### Web & Performance (Options 4-6)

These audit **websites** — you provide a URL, Prismo does the rest.

#### [4] Website Performance Audit
**What it does:** Measures how fast a website loads and identifies what's slowing it down.
**What it checks:** Core Web Vitals (LCP, FID, CLS), page weight, number of requests, render-blocking resources, image optimization, caching, compression.
**When to use it:** Before a website launch, or when a client says "our site is slow."
**Input needed:** Website URL (e.g., `example.com`).
**Good to know:** Uses Lighthouse CLI for accurate measurements when available.

#### [5] Tech Stack Analysis
**What it does:** Detects what technologies a website is built with.
**What it finds:** CMS (WordPress, Shopify, etc.), JavaScript frameworks (React, Vue, etc.), analytics tools, CDN provider, hosting, third-party integrations.
**When to use it:** During initial client assessment, or when evaluating a competitor's site.
**Input needed:** Website URL.

#### [6] Accessibility Audit (WCAG 2.1)
**What it does:** Checks if a website meets WCAG 2.1 AA accessibility standards.
**What it checks:** Color contrast, keyboard navigation, alt text, ARIA attributes, form labels, heading structure, focus management.
**When to use it:** Before launch (legal compliance), or when a client asks about accessibility.
**Input needed:** Website URL.

---

### SEO (Options 7-9)

#### [7] Technical SEO Audit
**What it does:** Checks the technical foundations of a site's SEO.
**What it checks:** robots.txt, sitemap.xml, canonical tags, hreflang, structured data (Schema.org), page speed, mobile-friendliness, crawlability, redirects, SSL.
**When to use it:** For any new client, before a site migration, or as a periodic health check.
**Input needed:** Website URL.

#### [8] On-page SEO Analysis
**What it does:** Analyzes the content and on-page SEO elements of a specific page.
**What it checks:** Title tags (length, keyword placement), meta descriptions, heading hierarchy, content quality, keyword usage, internal links, image optimization, Open Graph tags.
**When to use it:** When optimizing a specific landing page or blog post.
**Input needed:** Website URL (specific page, not just the homepage).

#### [9] Competitive SEO Snapshot
**What it does:** Compares a client's site against 2-3 competitors on visible SEO signals.
**What it checks:** Content strategy, keyword targeting, technical SEO maturity, structured data, site speed, mobile optimization.
**When to use it:** During strategy planning, when a client asks "how do we compare to competitors?"
**Input needed:** Client URL + comma-separated competitor URLs (e.g., `competitor1.com, competitor2.com`).

---

### MarTech & Data (Options 10-11)

#### [10] MarTech Stack Audit
**What it does:** Identifies all marketing technology on a website and evaluates the setup.
**What it finds:** Google Tag Manager, Google Analytics 4, Meta Pixel, LinkedIn Insight Tag, CRM integrations, email platforms, consent management platforms, A/B testing tools.
**When to use it:** During onboarding a new client, or when auditing tracking setup.
**Input needed:** Website URL.

#### [11] Data Quality Check
**What it does:** Verifies that analytics and tracking are configured correctly.
**What it checks:** Tag firing, data layer consistency, event tracking, Google Consent Mode v2, duplicate tags, PII leakage, UTM parameter handling.
**When to use it:** When analytics data looks suspicious, or before a major campaign launch.
**Input needed:** Website URL.

---

### Security (Options 12-13)

#### [12] Website Security Scan
**What it does:** Scans a website for security vulnerabilities and misconfigurations.
**What it checks:** SSL/TLS grade, security headers (CSP, HSTS, X-Frame-Options), CMS version disclosure, outdated JavaScript libraries, mixed content, cookie flags (Secure, HttpOnly, SameSite), CORS policy.
**When to use it:** During a security review, before launch, or after a security incident.
**Input needed:** Website URL.

#### [13] System Security Audit
**What it does:** Scans the local computer for security issues.
**What it checks (varies by OS):**
- **Windows:** Users/groups, password policies, open ports, firewall, antivirus, updates, RDP, SMBv1, BitLocker
- **macOS:** FileVault, Gatekeeper, SIP, firewall, SSH, profiles, launch agents
- **Linux:** Users, sudoers, SUID/SGID, SSH config, fail2ban, SELinux/AppArmor
**Input needed:** None — scans the local machine.

---

### Utilities (Options 14-15, 0)

#### [14] Interactive AI Session
**What it does:** Opens a direct conversation with the AI engine. You can ask anything — custom queries, follow-up questions, or tasks not covered by the menu.
**When to use it:** When you need something specific that isn't in the standard menu options.
**How to exit:** Type `/exit` or press `Ctrl+C`.

#### [15] Remote SSH Diagnostics
**What it does:** Connects to a remote server via SSH and runs diagnostics.
**When to use it:** When you need to diagnose a client's server remotely.
**Input needed:** SSH connection string (e.g., `admin@192.168.1.100`).
**Prerequisite:** SSH access must be configured (key-based or password).

#### [0] Safe USB Eject
**What it does:** Flushes all data, cleans up temporary files, and safely unmounts the USB drive.
**Always use this** instead of just pulling the USB out — it prevents data corruption.

---

## 8. Working with Reports

### Where reports are saved

All reports are automatically saved to:
```
USB_DRIVE/toolkit/reports/
```

Reports are in **Markdown format** (.md) — a text format that's readable as plain text but also renders beautifully in tools like GitHub, Notion, VS Code, or any Markdown viewer.

### Report naming

Reports are named with a timestamp:
```
toolkit/reports/session-2026-04-04_143052.log
```

### How to share reports with clients

**Option 1: As-is (Markdown)**
- Copy the `.md` file and send it by email
- Clients can open it in any text editor
- It looks best in GitHub, Notion, or a Markdown preview tool

**Option 2: Convert to PDF**
- Open the `.md` file in VS Code and use "Markdown PDF" extension
- Or paste it into Google Docs / Word for formatting
- Or use an online converter like [markdowntopdf.com](https://markdowntopdf.com)

**Option 3: Copy-paste into your proposal**
- Reports are structured with headers, tables, and bullet points
- Easy to copy relevant sections into a Google Doc or PowerPoint

### Report structure

Every report includes:
- **Header**: Date, client name, system info
- **Findings**: Organized by category with severity levels
- **Severity ratings**: CRITICAL → HIGH → MEDIUM → LOW
- **Remediation**: Specific, actionable fix instructions for each issue

---

## 9. Client Profiles

Client profiles let you store context about each client, so reports are automatically branded and the AI has relevant background.

### Creating a client profile

1. Open the `toolkit/clients/` folder on your USB
2. Create a new file named after the client, e.g., `acme-corp.json`
3. Add the following content:

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

### Setting the active client

Edit `prismo.config.json` on the root of your USB:

```json
{
  "client": {
    "name": "Acme Corp",
    "domain": "acme.com"
  }
}
```

The client name will appear in the Prismo banner and in all generated reports.

### Why bother with profiles?

- Reports are automatically branded with the client name
- You can track audit history over time
- Notes about the client's stack help the AI give more relevant advice
- When you revisit a client months later, you have full context

---

## 10. Configuration

The main configuration file is `prismo.config.json` at the root of your USB drive.

### Full configuration options

```json
{
  "version": "1.0.0",
  "language": "auto",
  "default_report_format": "markdown",
  "branding": {
    "agency": "diShine Digital Agency",
    "website": "https://dishine.it",
    "tagline": "Transform. Automate. Shine."
  },
  "client": {
    "name": "Client Name Here",
    "domain": "client.com",
    "notes": "Any relevant context"
  },
  "preferences": {
    "auto_save_reports": true,
    "report_dir": "toolkit/reports",
    "prompt_dir": "toolkit/prompts"
  }
}
```

### What each setting does

| Setting | What it does | Options |
|---------|-------------|---------|
| `language` | Default language for the interface | `"auto"`, `"it"`, `"en"`, `"fr"` |
| `default_report_format` | Format for saved reports | `"markdown"`, `"json"` |
| `branding.agency` | Your agency name in reports | Any text |
| `branding.website` | Your agency URL in reports | Any URL |
| `client.name` | Current client (shown in banner + reports) | Any text |
| `client.domain` | Client's website domain | e.g., `"acme.com"` |
| `auto_save_reports` | Automatically save every audit | `true` or `false` |

### Customizing for your own agency

If you fork Prismo for your own agency, change the `branding` section:

```json
{
  "branding": {
    "agency": "Your Agency Name",
    "website": "https://youragency.com",
    "tagline": "Your Tagline Here"
  }
}
```

---

## 11. Removing the USB Safely

**Always use the safe eject option** instead of just pulling out the USB drive.

### From the Prismo menu

Type **`0`** and press Enter. Prismo will:
1. Flush all pending data to the USB
2. Clean up temporary files from the computer
3. Unmount the USB drive safely
4. Tell you when it's safe to physically remove it

### If Prismo is not running

**Windows:**
- Right-click the USB drive in File Explorer → "Eject"
- Or run `prismo-eject.ps1` from PowerShell

**macOS:**
- Drag the USB icon to the Trash (it becomes an Eject icon)
- Or right-click → "Eject"

**Linux:**
- Right-click the USB in the file manager → "Unmount" or "Eject"
- Or run: `umount /media/$USER/USB_NAME`

---

## 12. Troubleshooting

### "Node.js not found" error

**Cause:** The setup script hasn't been run, or it failed partway through.
**Fix:** Re-run `setup-usb.ps1` on a Windows machine with internet access.

### "AI engine not found" error

**Cause:** The AI engine wasn't downloaded during setup.
**Fix:** Re-run `setup-usb.ps1`. If the issue persists, check that `engine/` folder has content.

### "Execution Policy" error on Windows

**Cause:** Windows blocks PowerShell scripts by default.
**Fix:** Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
Then retry.

### "Permission denied" on macOS/Linux

**Cause:** The USB might be mounted without execute permissions.
**Fix:** This is expected! Prismo extracts the runtime to `/tmp/` automatically, which has proper permissions. If you still get errors, try:
```bash
chmod +x /Volumes/USB_NAME/launch.sh
```

### "Authentication required" or "API key invalid"

**Cause:** Your Claude session has expired or credentials are invalid.
**Fix:**
1. Go to [claude.ai](https://claude.ai) and verify your subscription is active
2. Re-run `setup-usb.ps1` to refresh authentication
3. If using an API key, check it at [console.anthropic.com](https://console.anthropic.com)

### "SHA256 checksum warning"

**Cause:** One or more scripts on the USB have been modified since setup.
**What to do:**
- If **you** modified them (e.g., editing config): This is fine, press Enter to continue
- If you **didn't** modify anything: The USB may have been tampered with. Re-download Prismo from GitHub and re-run setup.

### Audits are slow or timing out

**Possible causes:**
- Slow internet connection (Prismo needs internet for the AI service)
- The target website is slow or blocking requests
- The AI engine is processing a complex audit

**Fix:** Wait a bit longer. If it consistently times out, check your internet connection.

### USB drive not recognized

**Try:**
1. Use a different USB port (prefer USB 3.0 ports)
2. Try a different cable if using a USB hub
3. On macOS, check System Information → USB
4. On Linux, run `lsblk` to see if the drive appears
5. Try a different USB drive (some cheap drives are unreliable)

---

## 13. Security & Privacy

### What data leaves the machine?

When you run an audit, the AI needs to process the data. This means:
- **Website audits (options 4-12):** The AI fetches the target website and analyzes it. The website content passes through the AI service.
- **System diagnostics (options 1, 3, 13):** System information (hardware specs, running services, log excerpts) is sent to the AI for analysis.
- **Log analysis (option 2):** The log file content is sent to the AI.

### What data stays on the USB?

- Authentication credentials (in `config/`)
- Generated reports (in `toolkit/reports/`)
- Session logs (in `toolkit/logs/`)
- Client profiles (in `toolkit/clients/`)

### Best practices

1. **Encrypt your USB drive**
   - Windows: Right-click the drive → "Turn on BitLocker"
   - macOS: Right-click → "Encrypt" (requires APFS format)
   - Linux: Use LUKS encryption

2. **Don't use on regulated systems**
   - Not suitable for GDPR-regulated personal data
   - Not suitable for HIPAA, PCI-DSS, or classified systems
   - The AI service processes data externally — use only on non-sensitive systems

3. **Rotate credentials**
   - Change your Claude password periodically
   - If using an API key, set spending limits at [console.anthropic.com](https://console.anthropic.com)

4. **If you lose the USB drive**
   - Immediately revoke your Claude session at [console.anthropic.com](https://console.anthropic.com)
   - Change your Claude password
   - If using an API key, revoke it and create a new one

5. **Review before confirming**
   - The AI may suggest running commands on the system
   - Always read what it proposes before confirming
   - Never approve destructive commands (delete, format, etc.) without understanding them

---

## 14. FAQ

### General

**Q: Do I need to install anything on the client's computer?**
A: No. Everything runs from the USB drive. Temporary files are created in the system's temp folder and cleaned up when you exit.

**Q: Does it work offline?**
A: No. Prismo needs an internet connection to communicate with the AI service. The website audits also need internet to fetch target URLs.

**Q: How much does it cost to run?**
A: You need a Claude subscription (starting at $20/month for Claude Pro). There's no additional cost for Prismo itself — it's free and open source.

**Q: Can I use it for commercial work?**
A: Yes. Prismo is MIT licensed. You can use it freely for client work, modify it for your agency, or redistribute it.

**Q: Which operating systems does it support?**
A: Windows 10/11, Windows Server 2016+, macOS 10.15+ (Intel and Apple Silicon), and Linux (x64 and ARM64).

### Usage

**Q: How long does a typical audit take?**
A: Most audits complete in 1-3 minutes. Complex ones (full system security, competitive SEO with multiple URLs) may take 5-10 minutes.

**Q: Can I audit multiple pages at once?**
A: The menu handles one URL at a time. For batch auditing, use option [14] (Interactive AI session) and ask the AI to audit multiple URLs in sequence.

**Q: Can I customize the audit prompts?**
A: Yes. The prompts are in `toolkit/prompts/` as Markdown files. Edit them to add or change what each audit checks. Changes take effect immediately — no restart needed.

**Q: What's the "Interactive AI session" (option 14)?**
A: It opens a free-form conversation with the AI. You can ask anything — follow-up questions about a previous audit, custom analyses, or tasks not covered by the standard menu.

### Technical

**Q: Why does setup require Windows?**
A: The setup script (`setup-usb.ps1`) uses PowerShell to download and configure everything. This is a one-time step. After setup, the USB works on all platforms.

**Q: Can I run the setup on macOS or Linux instead?**
A: Not with the current setup script. However, you can manually install Node.js and the AI engine on any platform. See the README for the USB drive structure.

**Q: How do I update Prismo?**
A: Download the latest version from GitHub, copy the new files to your USB (replacing the old ones), and re-run `setup-usb.ps1` to update the runtime.

**Q: Can multiple people use the same USB?**
A: Yes, but they'll share the same Claude credentials and client profiles. For separate accounts, prepare a USB drive for each consultant.

**Q: The USB drive is full. What do I do?**
A: Delete old reports from `toolkit/reports/` and old session logs from `toolkit/logs/`. The runtime and engine files should not be deleted.

---

## Getting Help

- **GitHub Issues:** [github.com/diShine-digital-agency/prismo/issues](https://github.com/diShine-digital-agency/prismo/issues)
- **Documentation:** [github.com/diShine-digital-agency/prismo](https://github.com/diShine-digital-agency/prismo)
- **diShine Digital Agency:** [dishine.it](https://dishine.it)

---

*This guide is part of Prismo by diShine Digital Agency. MIT License.*
