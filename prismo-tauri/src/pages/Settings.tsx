import { useState } from "react";

export default function Settings() {
  const [language, setLanguage] = useState("en");
  const [apiKey, setApiKey] = useState("");
  const [showApiKey, setShowApiKey] = useState(false);
  const [agencyName, setAgencyName] = useState("diShine Digital Agency");
  const [agencyWebsite, setAgencyWebsite] = useState("https://dishine.it");
  const [autoSaveReports, setAutoSaveReports] = useState(true);
  const [theme, setTheme] = useState("dark");
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="p-8 max-w-2xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white mb-2">Settings</h1>
        <p className="text-gray-400">Configure Prismo to your preferences.</p>
      </div>

      <div className="space-y-6">
        {/* General */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">General</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1.5">Language</label>
              <select
                value={language}
                onChange={(e) => setLanguage(e.target.value)}
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-gray-200 focus:outline-none focus:border-purple-500"
              >
                <option value="en">English</option>
                <option value="it">Italiano</option>
                <option value="fr">Français</option>
              </select>
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1.5">Theme</label>
              <select
                value={theme}
                onChange={(e) => setTheme(e.target.value)}
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-gray-200 focus:outline-none focus:border-purple-500"
              >
                <option value="dark">Dark Mode</option>
                <option value="light">Light Mode (coming soon)</option>
              </select>
            </div>
            <div className="flex items-center justify-between">
              <div>
                <label className="text-sm text-gray-300">Auto-save reports</label>
                <p className="text-xs text-gray-500">Save reports automatically after each audit</p>
              </div>
              <button
                onClick={() => setAutoSaveReports(!autoSaveReports)}
                className={`relative w-12 h-6 rounded-full transition-colors ${
                  autoSaveReports ? "bg-purple-600" : "bg-gray-700"
                }`}
              >
                <div
                  className={`absolute top-0.5 w-5 h-5 rounded-full bg-white transition-transform ${
                    autoSaveReports ? "translate-x-6" : "translate-x-0.5"
                  }`}
                />
              </button>
            </div>
          </div>
        </div>

        {/* API Configuration */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">AI Engine</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1.5">
                Anthropic API Key
              </label>
              <div className="relative">
                <input
                  type={showApiKey ? "text" : "password"}
                  value={apiKey}
                  onChange={(e) => setApiKey(e.target.value)}
                  placeholder="sk-ant-api..."
                  className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 pr-12 text-gray-200 placeholder-gray-600 focus:outline-none focus:border-purple-500 font-mono text-sm"
                />
                <button
                  onClick={() => setShowApiKey(!showApiKey)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-300"
                >
                  {showApiKey ? "🙈" : "👁️"}
                </button>
              </div>
              <p className="text-xs text-gray-500 mt-1">
                Get your API key from{" "}
                <span className="text-purple-400">console.anthropic.com</span>
              </p>
            </div>
          </div>
        </div>

        {/* Branding */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Branding</h2>
          <p className="text-xs text-gray-500 mb-4">
            Customize the agency name and website shown on reports. Use this for white-label mode.
          </p>
          <div className="space-y-4">
            <div>
              <label className="block text-sm text-gray-400 mb-1.5">Agency Name</label>
              <input
                type="text"
                value={agencyName}
                onChange={(e) => setAgencyName(e.target.value)}
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-gray-200 focus:outline-none focus:border-purple-500"
              />
            </div>
            <div>
              <label className="block text-sm text-gray-400 mb-1.5">Agency Website</label>
              <input
                type="text"
                value={agencyWebsite}
                onChange={(e) => setAgencyWebsite(e.target.value)}
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-gray-200 focus:outline-none focus:border-purple-500"
              />
            </div>
          </div>
        </div>

        {/* Brand Colors Preview */}
        <div className="bg-gray-900 border border-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Brand Colors</h2>
          <div className="grid grid-cols-3 gap-3">
            {[
              { name: "Prismo Purple", hex: "#6C5CE7" },
              { name: "Teal Accent", hex: "#00CEC9" },
              { name: "Charcoal", hex: "#2D3436" },
              { name: "Success", hex: "#00B894" },
              { name: "Warning", hex: "#FDCB6E" },
              { name: "Danger", hex: "#E17055" },
            ].map((color) => (
              <div key={color.name} className="flex items-center gap-2">
                <div
                  className="w-8 h-8 rounded-lg border border-gray-700"
                  style={{ backgroundColor: color.hex }}
                />
                <div>
                  <p className="text-xs text-gray-300">{color.name}</p>
                  <p className="text-xs text-gray-500 font-mono">{color.hex}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Save Button */}
        <button
          onClick={handleSave}
          className={`w-full py-3 rounded-lg font-medium transition-all ${
            saved
              ? "bg-green-600 text-white"
              : "bg-purple-600 hover:bg-purple-700 text-white"
          }`}
        >
          {saved ? "✓ Saved!" : "Save Settings"}
        </button>
      </div>
    </div>
  );
}
