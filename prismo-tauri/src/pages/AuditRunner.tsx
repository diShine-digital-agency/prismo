import { useState } from "react";
import { invoke } from "@tauri-apps/api/core";
import AuditCard from "../components/AuditCard";

interface AuditPrompt {
  id: string;
  name: string;
  category: string;
  description: string;
  filename: string;
}

const auditIcons: Record<string, string> = {
  "windows-health": "🖥️",
  "linux-health": "🐧",
  "macos-health": "🍎",
  "log-analysis": "📋",
  "network-diagnosis": "🌐",
  "website-performance": "⚡",
  "tech-stack": "🔧",
  "accessibility": "♿",
  "seo-technical": "🔎",
  "seo-onpage": "📝",
  "seo-competitive": "📊",
  "martech-stack": "📈",
  "data-quality": "🎯",
  "website-security": "🔒",
  "system-security": "🛡️",
  "email-dns": "📧",
  "gdpr-privacy": "🏛️",
  "social-media": "📱",
  "api-security": "🔌",
};

const categories = [
  "All",
  "System Health",
  "Web & Performance",
  "SEO",
  "MarTech & Data",
  "Security",
  "Email & DNS",
  "Privacy",
  "Social",
  "API",
];

export default function AuditRunner() {
  const [audits] = useState<AuditPrompt[]>(() => {
    // Initialize synchronously with default data, then try to fetch from backend
    return [
      { id: "windows-health", name: "Windows System Diagnosis", category: "System Health", description: "CPU, RAM, disk, services, logs, pending updates", filename: "system/windows-health.md" },
      { id: "linux-health", name: "Linux System Diagnosis", category: "System Health", description: "OS, hardware, storage, services, logs, network", filename: "system/linux-health.md" },
      { id: "macos-health", name: "macOS System Diagnosis", category: "System Health", description: "APFS, Time Machine, daemons, security, performance", filename: "system/macos-health.md" },
      { id: "log-analysis", name: "Log Analysis", category: "System Health", description: "Parse any log file for errors, warnings, and patterns", filename: "system/log-analysis.md" },
      { id: "network-diagnosis", name: "Network Diagnostics", category: "System Health", description: "Interfaces, DNS, routing, ports, firewall, connectivity", filename: "system/network-diagnosis.md" },
      { id: "website-performance", name: "Website Performance", category: "Web & Performance", description: "Core Web Vitals (LCP, INP, CLS), Lighthouse metrics", filename: "web/website-performance.md" },
      { id: "tech-stack", name: "Tech Stack Analysis", category: "Web & Performance", description: "Frameworks, CMS, hosting, CDN, third-party scripts", filename: "web/tech-stack-analysis.md" },
      { id: "accessibility", name: "Accessibility Audit", category: "Web & Performance", description: "WCAG 2.1 AA compliance checks", filename: "web/accessibility-audit.md" },
      { id: "seo-technical", name: "Technical SEO", category: "SEO", description: "robots.txt, sitemaps, canonicals, schema, hreflang, redirects", filename: "seo/seo-technical.md" },
      { id: "seo-onpage", name: "On-Page SEO", category: "SEO", description: "Titles, metas, headings, content quality, internal links", filename: "seo/seo-onpage.md" },
      { id: "seo-competitive", name: "Competitive SEO", category: "SEO", description: "Side-by-side SEO comparison against competitors", filename: "seo/seo-competitive.md" },
      { id: "martech-stack", name: "MarTech Stack", category: "MarTech & Data", description: "GTM, GA4, pixels, CRM, consent management", filename: "martech/martech-stack-audit.md" },
      { id: "data-quality", name: "Data Quality", category: "MarTech & Data", description: "Event tracking, UTM consistency, data layer validation", filename: "martech/martech-data-quality.md" },
      { id: "website-security", name: "Website Security", category: "Security", description: "SSL/TLS, security headers, CMS vulnerabilities, cookie flags", filename: "security/website-security.md" },
      { id: "system-security", name: "System Security", category: "Security", description: "Users, permissions, firewall, SSH, encryption, patching", filename: "security/system-security.md" },
      { id: "email-dns", name: "Email & DNS Audit", category: "Email & DNS", description: "SPF, DKIM, DMARC, MX records, DNS security", filename: "email-dns/email-dns-audit.md" },
      { id: "gdpr-privacy", name: "GDPR & Privacy", category: "Privacy", description: "Cookie consent, privacy policy, data collection compliance", filename: "privacy/gdpr-privacy-audit.md" },
      { id: "social-media", name: "Social Media & Structured Data", category: "Social", description: "Open Graph, Twitter Cards, Schema.org markup", filename: "social/social-media-audit.md" },
      { id: "api-security", name: "API Security", category: "API", description: "Endpoints, auth, CORS, rate limiting, error handling", filename: "api/api-security-audit.md" },
    ];
  });

  const [selectedCategory, setSelectedCategory] = useState("All");
  const [selectedAudit, setSelectedAudit] = useState<AuditPrompt | null>(null);
  const [targetUrl, setTargetUrl] = useState("");
  const [isRunning, setIsRunning] = useState(false);
  const [output, setOutput] = useState("");

  const filteredAudits = selectedCategory === "All"
    ? audits
    : audits.filter((a) => a.category === selectedCategory);

  const handleRunAudit = async () => {
    if (!selectedAudit) return;
    setIsRunning(true);
    setOutput("Starting audit...\n\nConnecting to AI engine...\n");

    try {
      // In a full implementation, this would invoke the Claude CLI via Tauri shell plugin
      const systemInfo = await invoke<{ os: string; arch: string }>("get_system_info");
      setOutput((prev) =>
        prev +
        `\nSystem: ${systemInfo.os} (${systemInfo.arch})\n` +
        `Audit: ${selectedAudit.name}\n` +
        `Target: ${targetUrl || "local system"}\n` +
        `Prompt: toolkit/prompts/${selectedAudit.filename}\n\n` +
        `⏳ To run this audit, the AI engine (Claude Code) needs to be configured.\n` +
        `   Use the CLI launcher (launch.sh / launch.bat) to run audits with the AI engine,\n` +
        `   or configure your API key in Settings.\n\n` +
        `📋 Prompt loaded: ${selectedAudit.filename}\n`
      );
    } catch (e) {
      setOutput((prev) => prev + `\nError: ${e}\n`);
    }

    setIsRunning(false);
  };

  if (selectedAudit) {
    return (
      <div className="p-8 max-w-4xl mx-auto">
        {/* Back button */}
        <button
          onClick={() => { setSelectedAudit(null); setOutput(""); }}
          className="text-sm text-gray-400 hover:text-gray-200 mb-6 flex items-center gap-1 transition-colors"
        >
          ← Back to audits
        </button>

        {/* Audit Header */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6 mb-6">
          <div className="flex items-center gap-4 mb-4">
            <span className="text-3xl">{auditIcons[selectedAudit.id] || "🔍"}</span>
            <div>
              <h1 className="text-2xl font-bold text-white">{selectedAudit.name}</h1>
              <p className="text-gray-400">{selectedAudit.description}</p>
            </div>
          </div>

          {/* Target URL input */}
          {!selectedAudit.id.includes("health") && !selectedAudit.id.includes("log-analysis") && !selectedAudit.id.includes("system-security") && (
            <div className="mb-4">
              <label className="block text-sm text-gray-400 mb-2">Target URL or Domain</label>
              <input
                type="text"
                value={targetUrl}
                onChange={(e) => setTargetUrl(e.target.value)}
                placeholder="https://example.com"
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-3 text-gray-200 placeholder-gray-600 focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500"
              />
            </div>
          )}

          <button
            onClick={handleRunAudit}
            disabled={isRunning}
            className="bg-purple-600 hover:bg-purple-700 disabled:bg-gray-700 disabled:text-gray-500 text-white font-medium px-6 py-3 rounded-lg transition-colors flex items-center gap-2"
          >
            {isRunning ? (
              <>
                <span className="animate-spin">⏳</span> Running...
              </>
            ) : (
              <>🚀 Run Audit</>
            )}
          </button>
        </div>

        {/* Output */}
        {output && (
          <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
            <h2 className="text-sm font-medium text-gray-400 mb-3">Output</h2>
            <pre className="bg-gray-950 rounded-lg p-4 text-sm text-gray-300 font-mono whitespace-pre-wrap overflow-auto max-h-96">
              {output}
            </pre>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white mb-2">Run Audit</h1>
        <p className="text-gray-400">Select an audit to run. 19 diagnostics across 9 categories.</p>
      </div>

      {/* Category Filter */}
      <div className="flex flex-wrap gap-2 mb-6">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
              selectedCategory === cat
                ? "bg-purple-600 text-white"
                : "bg-gray-800 text-gray-400 hover:text-gray-200 hover:bg-gray-700"
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Audit Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredAudits.map((audit) => (
          <AuditCard
            key={audit.id}
            name={audit.name}
            category={audit.category}
            description={audit.description}
            icon={auditIcons[audit.id] || "🔍"}
            onClick={() => setSelectedAudit(audit)}
          />
        ))}
      </div>
    </div>
  );
}
