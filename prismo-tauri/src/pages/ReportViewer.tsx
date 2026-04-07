import Markdown from "react-markdown";

interface ReportViewerProps {
  content: string;
  onBack: () => void;
}

export default function ReportViewer({ content, onBack }: ReportViewerProps) {
  const handleExportMarkdown = () => {
    const blob = new Blob([content], { type: "text/markdown" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `prismo-report-${new Date().toISOString().split("T")[0]}.md`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleExportTxt = () => {
    const plainText = content
      .replace(/#{1,6}\s/g, "")
      .replace(/\*\*/g, "")
      .replace(/\*/g, "")
      .replace(/`/g, "")
      .replace(/\|/g, " ")
      .replace(/---+/g, "────────────────────────────────");
    const blob = new Blob([plainText], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `prismo-report-${new Date().toISOString().split("T")[0]}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleExportHtml = () => {
    // Render to HTML with branding
    const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Prismo Audit Report</title>
  <style>
    body { font-family: 'Inter', 'Segoe UI', sans-serif; max-width: 800px; margin: 0 auto; padding: 40px; color: #2D3436; }
    h1 { color: #6C5CE7; border-bottom: 3px solid #6C5CE7; padding-bottom: 8px; }
    h2 { color: #2D3436; border-bottom: 1px solid #DFE6E9; padding-bottom: 6px; margin-top: 24px; }
    h3 { color: #6C5CE7; }
    table { width: 100%; border-collapse: collapse; margin: 16px 0; }
    th { background-color: #6C5CE7; color: white; padding: 10px 12px; text-align: left; }
    td { padding: 8px 12px; border-bottom: 1px solid #DFE6E9; }
    tr:nth-child(even) { background-color: #F5F6FA; }
    code { background-color: #F5F6FA; padding: 2px 6px; border-radius: 3px; color: #E17055; }
    pre { background-color: #2D3436; color: #F5F6FA; padding: 16px; border-radius: 6px; }
    blockquote { border-left: 4px solid #6C5CE7; padding-left: 16px; color: #636E72; }
    .footer { text-align: center; margin-top: 40px; padding-top: 16px; border-top: 1px solid #DFE6E9; color: #999; font-size: 12px; }
    @media print {
      @page { margin: 25mm 20mm; }
      body { font-size: 11pt; }
    }
  </style>
</head>
<body>
  <div id="content">${content.replace(/</g, "&lt;").replace(/>/g, "&gt;")}</div>
  <div class="footer">
    Powered by Prismo | diShine Digital Agency | dishine.it
  </div>
</body>
</html>`;

    const blob = new Blob([htmlContent], { type: "text/html" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `prismo-report-${new Date().toISOString().split("T")[0]}.html`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="p-8 max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <button
          onClick={onBack}
          className="text-sm text-gray-400 hover:text-gray-200 flex items-center gap-1 transition-colors"
        >
          ← Back to reports
        </button>
        <div className="flex items-center gap-2">
          <button
            onClick={handleExportMarkdown}
            className="bg-gray-800 hover:bg-gray-700 text-gray-300 px-3 py-2 rounded-lg text-sm transition-colors flex items-center gap-1.5"
          >
            📋 Markdown
          </button>
          <button
            onClick={handleExportTxt}
            className="bg-gray-800 hover:bg-gray-700 text-gray-300 px-3 py-2 rounded-lg text-sm transition-colors flex items-center gap-1.5"
          >
            📝 Text
          </button>
          <button
            onClick={handleExportHtml}
            className="bg-gray-800 hover:bg-gray-700 text-gray-300 px-3 py-2 rounded-lg text-sm transition-colors flex items-center gap-1.5"
          >
            🌐 HTML
          </button>
          <button
            onClick={handlePrint}
            className="bg-purple-600 hover:bg-purple-700 text-white px-3 py-2 rounded-lg text-sm transition-colors flex items-center gap-1.5"
          >
            🖨️ Print / PDF
          </button>
        </div>
      </div>

      {/* Report Content */}
      <div className="bg-gray-900 border border-gray-800 rounded-xl p-8 prose max-w-none">
        <Markdown>{content}</Markdown>
      </div>
    </div>
  );
}
