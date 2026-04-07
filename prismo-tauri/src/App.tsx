import { useState } from "react";
import Sidebar from "./components/Sidebar";
import Dashboard from "./pages/Dashboard";
import AuditRunner from "./pages/AuditRunner";
import Reports from "./pages/Reports";
import ReportViewer from "./pages/ReportViewer";
import ClientManager from "./pages/ClientManager";
import Settings from "./pages/Settings";
import ExportCenter from "./pages/ExportCenter";

export type Page = "dashboard" | "audits" | "reports" | "report-viewer" | "clients" | "settings" | "export";

function App() {
  const [currentPage, setCurrentPage] = useState<Page>("dashboard");
  const [selectedReport, setSelectedReport] = useState<string>("");

  const navigateToReport = (content: string) => {
    setSelectedReport(content);
    setCurrentPage("report-viewer");
  };

  const renderPage = () => {
    switch (currentPage) {
      case "dashboard":
        return <Dashboard onNavigate={setCurrentPage} />;
      case "audits":
        return <AuditRunner />;
      case "reports":
        return <Reports onViewReport={navigateToReport} />;
      case "report-viewer":
        return <ReportViewer content={selectedReport} onBack={() => setCurrentPage("reports")} />;
      case "clients":
        return <ClientManager />;
      case "settings":
        return <Settings />;
      case "export":
        return <ExportCenter />;
      default:
        return <Dashboard onNavigate={setCurrentPage} />;
    }
  };

  return (
    <div className="flex h-screen bg-gray-950 text-gray-100 overflow-hidden">
      <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
      <main className="flex-1 overflow-y-auto">
        {renderPage()}
      </main>
    </div>
  );
}

export default App;
