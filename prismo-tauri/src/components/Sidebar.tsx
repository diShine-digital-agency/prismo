import type { Page } from "../App";

const navItems: { id: Page; label: string; icon: string }[] = [
  { id: "dashboard", label: "Dashboard", icon: "📊" },
  { id: "audits", label: "Run Audit", icon: "🔍" },
  { id: "reports", label: "Reports", icon: "📄" },
  { id: "export", label: "Export", icon: "📤" },
  { id: "clients", label: "Clients", icon: "👥" },
  { id: "settings", label: "Settings", icon: "⚙️" },
];

interface SidebarProps {
  currentPage: Page;
  onNavigate: (page: Page) => void;
}

export default function Sidebar({ currentPage, onNavigate }: SidebarProps) {
  return (
    <aside className="w-64 bg-gray-900 border-r border-gray-800 flex flex-col">
      {/* Brand Header */}
      <div className="p-6 border-b border-gray-800">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-purple-700 flex items-center justify-center text-white font-bold text-lg shadow-lg shadow-purple-500/20">
            P
          </div>
          <div>
            <h1 className="text-lg font-bold text-white tracking-tight">Prismo</h1>
            <p className="text-xs text-gray-500">AI Consulting Toolkit</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map((item) => (
          <button
            key={item.id}
            onClick={() => onNavigate(item.id)}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-all duration-150 ${
              currentPage === item.id
                ? "bg-purple-600/20 text-purple-400 border border-purple-500/30"
                : "text-gray-400 hover:text-gray-200 hover:bg-gray-800/60"
            }`}
          >
            <span className="text-lg">{item.icon}</span>
            <span>{item.label}</span>
          </button>
        ))}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-gray-800">
        <div className="text-center">
          <p className="text-xs text-gray-600">Powered by</p>
          <p className="text-xs text-purple-400 font-medium">diShine Digital Agency</p>
          <p className="text-xs text-gray-600 mt-1">v1.0.0</p>
        </div>
      </div>
    </aside>
  );
}
