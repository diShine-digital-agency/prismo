import type { Page } from "../App";

interface DashboardProps {
  onNavigate: (page: Page) => void;
}

const stats = [
  { label: "Audit Categories", value: "9", icon: "📁", color: "text-purple-400" },
  { label: "Available Audits", value: "19", icon: "🔍", color: "text-teal-400" },
  { label: "Export Formats", value: "4", icon: "📤", color: "text-amber-400" },
  { label: "Languages", value: "3", icon: "🌐", color: "text-blue-400" },
];

const quickActions = [
  { label: "Website Performance", icon: "⚡", category: "Web & Performance", description: "Core Web Vitals, Lighthouse" },
  { label: "Technical SEO", icon: "🔎", category: "SEO", description: "Crawlability, indexability, schema" },
  { label: "Website Security", icon: "🔒", category: "Security", description: "SSL, headers, vulnerabilities" },
  { label: "GDPR & Privacy", icon: "🛡️", category: "Privacy", description: "Cookie consent, compliance" },
  { label: "Email & DNS", icon: "📧", category: "Email & DNS", description: "SPF, DKIM, DMARC" },
  { label: "API Security", icon: "🔌", category: "API", description: "Auth, CORS, rate limiting" },
];

export default function Dashboard({ onNavigate }: DashboardProps) {
  return (
    <div className="p-8 max-w-6xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">
          Welcome to <span className="text-purple-400">Prismo</span>
        </h1>
        <p className="text-gray-400 text-lg">
          AI-powered consulting toolkit for digital audits and diagnostics.
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {stats.map((stat) => (
          <div key={stat.label} className="bg-gray-900 border border-gray-800 rounded-xl p-5">
            <div className="flex items-center gap-3 mb-3">
              <span className="text-2xl">{stat.icon}</span>
              <span className={`text-3xl font-bold ${stat.color}`}>{stat.value}</span>
            </div>
            <p className="text-sm text-gray-500">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* Quick Actions */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-white">Quick Start</h2>
          <button
            onClick={() => onNavigate("audits")}
            className="text-sm text-purple-400 hover:text-purple-300 transition-colors"
          >
            View all audits →
          </button>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {quickActions.map((action) => (
            <button
              key={action.label}
              onClick={() => onNavigate("audits")}
              className="bg-gray-900 border border-gray-800 rounded-xl p-5 text-left hover:border-purple-500/40 hover:bg-gray-900/80 transition-all group"
            >
              <div className="flex items-start gap-3">
                <span className="text-2xl group-hover:scale-110 transition-transform">{action.icon}</span>
                <div>
                  <h3 className="font-medium text-gray-200 mb-1">{action.label}</h3>
                  <p className="text-xs text-gray-500">{action.description}</p>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Info Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* How It Works */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">How It Works</h2>
          <div className="space-y-4">
            {[
              { step: "1", title: "Select an audit", desc: "Choose from 19 diagnostic options across 9 categories" },
              { step: "2", title: "Provide context", desc: "Enter the target URL or system to analyze" },
              { step: "3", title: "AI analyzes", desc: "Claude collects data and generates insights" },
              { step: "4", title: "Export results", desc: "Download branded PDF, Markdown, or HTML reports" },
            ].map((item) => (
              <div key={item.step} className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-full bg-purple-600/30 border border-purple-500/40 flex items-center justify-center text-purple-400 text-sm font-bold shrink-0">
                  {item.step}
                </div>
                <div>
                  <h3 className="text-sm font-medium text-gray-200">{item.title}</h3>
                  <p className="text-xs text-gray-500">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* About */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">About Prismo</h2>
          <p className="text-sm text-gray-400 mb-4 leading-relaxed">
            Prismo is a zero-footprint AI consulting toolkit. It bundles a portable Node.js runtime
            with Claude Code and a library of diagnostic prompts. It runs audits across system health,
            web performance, SEO, MarTech, security, and more — without installing anything on the
            client's machine.
          </p>
          <div className="flex items-center gap-4 pt-3 border-t border-gray-800">
            <div>
              <p className="text-xs text-gray-500">Built by</p>
              <p className="text-sm text-purple-400 font-medium">diShine Digital Agency</p>
            </div>
            <div className="ml-auto">
              <p className="text-xs text-gray-500">Version</p>
              <p className="text-sm text-gray-300 font-mono">1.0.0</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
