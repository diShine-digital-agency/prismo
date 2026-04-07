import { useState } from "react";

const exportFormats = [
  {
    id: "pdf",
    name: "PDF",
    icon: "📕",
    description: "Professional branded PDF with cover page, headers, and footers. Best for client delivery.",
    branded: true,
    printable: true,
    status: "available",
    howTo: "Use the Print / PDF button in the Report Viewer, or use md-to-pdf with the branded CSS template.",
  },
  {
    id: "html",
    name: "HTML",
    icon: "🌐",
    description: "Styled HTML with full branding, viewable in any browser. Great for email or web embedding.",
    branded: true,
    printable: true,
    status: "available",
    howTo: "Click the HTML export button in the Report Viewer.",
  },
  {
    id: "markdown",
    name: "Markdown",
    icon: "📋",
    description: "Native format, renders in GitHub, VS Code, or any Markdown viewer.",
    branded: true,
    printable: false,
    status: "available",
    howTo: "Click the Markdown export button in the Report Viewer.",
  },
  {
    id: "txt",
    name: "Plain Text",
    icon: "📝",
    description: "Simple text format, no formatting. Universal compatibility.",
    branded: false,
    printable: true,
    status: "available",
    howTo: "Click the Text export button in the Report Viewer.",
  },
];

export default function ExportCenter() {
  const [selectedFormat, setSelectedFormat] = useState<string | null>(null);

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white mb-2">Export Center</h1>
        <p className="text-gray-400">
          Export your audit reports in multiple branded formats.
        </p>
      </div>

      {/* Format Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {exportFormats.map((format) => (
          <button
            key={format.id}
            onClick={() => setSelectedFormat(selectedFormat === format.id ? null : format.id)}
            className={`bg-gray-900 border rounded-xl p-5 text-left transition-all ${
              selectedFormat === format.id
                ? "border-purple-500/50 bg-purple-600/5"
                : "border-gray-800 hover:border-gray-700"
            }`}
          >
            <div className="flex items-start gap-4">
              <span className="text-3xl">{format.icon}</span>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <h3 className="font-semibold text-gray-200">{format.name}</h3>
                  {format.branded && (
                    <span className="text-xs bg-purple-500/20 text-purple-400 px-1.5 py-0.5 rounded">
                      Branded
                    </span>
                  )}
                  {format.printable && (
                    <span className="text-xs bg-teal-500/20 text-teal-400 px-1.5 py-0.5 rounded">
                      Printable
                    </span>
                  )}
                </div>
                <p className="text-sm text-gray-400">{format.description}</p>

                {selectedFormat === format.id && (
                  <div className="mt-3 pt-3 border-t border-gray-800">
                    <p className="text-sm text-gray-300 font-medium mb-1">How to export:</p>
                    <p className="text-sm text-gray-400">{format.howTo}</p>
                  </div>
                )}
              </div>
            </div>
          </button>
        ))}
      </div>

      {/* CLI Export Guide */}
      <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 mb-6">
        <h2 className="text-lg font-semibold text-white mb-4">CLI Export with md-to-pdf</h2>
        <p className="text-sm text-gray-400 mb-4">
          For advanced PDF generation with full branding control, use the md-to-pdf tool:
        </p>
        <pre className="bg-gray-950 rounded-lg p-4 text-sm text-gray-300 font-mono overflow-auto">
{`# Install md-to-pdf (one-time)
npm install -g md-to-pdf

# Convert a report to branded PDF
npx md-to-pdf toolkit/reports/your-report.md \\
  --stylesheet toolkit/export/report-style.css

# Convert to HTML
npx md-to-pdf toolkit/reports/your-report.md \\
  --stylesheet toolkit/export/report-style.css \\
  --as-html`}
        </pre>
      </div>

      {/* Branding Preview */}
      <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
        <h2 className="text-lg font-semibold text-white mb-4">Report Branding Preview</h2>
        <div className="bg-white rounded-lg p-6 text-gray-900">
          <div className="border-b-2 border-purple-600 pb-4 mb-4">
            <div className="flex items-center justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-lg bg-purple-600 flex items-center justify-center text-white font-bold text-sm">
                    P
                  </div>
                  <span className="text-lg font-bold text-purple-600">PRISMO</span>
                </div>
              </div>
              <span className="text-sm text-gray-500 font-medium">AUDIT REPORT</span>
            </div>
          </div>
          <div className="space-y-1 text-sm">
            <p><span className="font-medium text-gray-600">Client:</span> Acme Corp</p>
            <p><span className="font-medium text-gray-600">Domain:</span> acme.com</p>
            <p><span className="font-medium text-gray-600">Date:</span> 2026-04-07</p>
            <p><span className="font-medium text-gray-600">Audit:</span> Website Performance</p>
          </div>
          <div className="border-t border-gray-200 mt-4 pt-3 flex items-center justify-between text-xs text-gray-400">
            <span>Powered by Prismo | diShine Digital Agency | dishine.it</span>
            <span>Page 1 of 3</span>
          </div>
        </div>
      </div>
    </div>
  );
}
