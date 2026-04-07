# Prismo Report Export

Export audit reports as branded PDF, HTML, Markdown, or plain text.

## Quick Export (PDF)

```bash
npm install -g md-to-pdf
npx md-to-pdf toolkit/reports/your-report.md --stylesheet toolkit/export/report-style.css
```

## Formats

| Format | Command | Branded |
|--------|---------|---------|
| PDF | `npx md-to-pdf report.md --stylesheet toolkit/export/report-style.css` | ✅ |
| HTML | `npx md-to-pdf report.md --stylesheet toolkit/export/report-style.css --as-html` | ✅ |
| Markdown | Native format | ✅ |
| Plain Text | `sed 's/[#*_\`]//g' report.md > report.txt` | 🟡 |

## Customizing

Edit `report-style.css` to change colors, fonts, and branding.
Edit `prismo.config.json` branding section for white-label use.
