use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Serialize, Deserialize, Clone)]
pub struct AuditPrompt {
    pub id: String,
    pub name: String,
    pub category: String,
    pub description: String,
    pub filename: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct ClientProfile {
    pub name: String,
    pub domain: String,
    pub industry: String,
    pub notes: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct PrismoConfig {
    pub version: String,
    pub language: String,
    pub default_report_format: String,
    pub branding: BrandingConfig,
    pub client: ClientProfile,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct BrandingConfig {
    pub agency: String,
    pub website: String,
}

#[derive(Serialize, Deserialize)]
pub struct ReportMeta {
    pub filename: String,
    pub title: String,
    pub date: String,
    pub size: u64,
}

#[tauri::command]
fn get_audit_prompts() -> Vec<AuditPrompt> {
    vec![
        AuditPrompt { id: "windows-health".into(), name: "Windows System Diagnosis".into(), category: "System Health".into(), description: "CPU, RAM, disk, services, logs, pending updates".into(), filename: "system/windows-health.md".into() },
        AuditPrompt { id: "linux-health".into(), name: "Linux System Diagnosis".into(), category: "System Health".into(), description: "OS, hardware, storage, services, logs, network".into(), filename: "system/linux-health.md".into() },
        AuditPrompt { id: "macos-health".into(), name: "macOS System Diagnosis".into(), category: "System Health".into(), description: "APFS, Time Machine, daemons, security, performance".into(), filename: "system/macos-health.md".into() },
        AuditPrompt { id: "log-analysis".into(), name: "Log Analysis".into(), category: "System Health".into(), description: "Parse any log file for errors, warnings, and patterns".into(), filename: "system/log-analysis.md".into() },
        AuditPrompt { id: "network-diagnosis".into(), name: "Network Diagnostics".into(), category: "System Health".into(), description: "Interfaces, DNS, routing, ports, firewall, connectivity".into(), filename: "system/network-diagnosis.md".into() },
        AuditPrompt { id: "website-performance".into(), name: "Website Performance".into(), category: "Web & Performance".into(), description: "Core Web Vitals (LCP, INP, CLS), Lighthouse metrics".into(), filename: "web/website-performance.md".into() },
        AuditPrompt { id: "tech-stack".into(), name: "Tech Stack Analysis".into(), category: "Web & Performance".into(), description: "Frameworks, CMS, hosting, CDN, third-party scripts".into(), filename: "web/tech-stack-analysis.md".into() },
        AuditPrompt { id: "accessibility".into(), name: "Accessibility Audit".into(), category: "Web & Performance".into(), description: "WCAG 2.1 AA compliance checks".into(), filename: "web/accessibility-audit.md".into() },
        AuditPrompt { id: "seo-technical".into(), name: "Technical SEO".into(), category: "SEO".into(), description: "robots.txt, sitemaps, canonicals, schema, hreflang, redirects".into(), filename: "seo/seo-technical.md".into() },
        AuditPrompt { id: "seo-onpage".into(), name: "On-Page SEO".into(), category: "SEO".into(), description: "Titles, metas, headings, content quality, internal links".into(), filename: "seo/seo-onpage.md".into() },
        AuditPrompt { id: "seo-competitive".into(), name: "Competitive SEO".into(), category: "SEO".into(), description: "Side-by-side SEO comparison against competitors".into(), filename: "seo/seo-competitive.md".into() },
        AuditPrompt { id: "martech-stack".into(), name: "MarTech Stack".into(), category: "MarTech & Data".into(), description: "GTM, GA4, pixels, CRM, consent management".into(), filename: "martech/martech-stack-audit.md".into() },
        AuditPrompt { id: "data-quality".into(), name: "Data Quality".into(), category: "MarTech & Data".into(), description: "Event tracking, UTM consistency, data layer validation".into(), filename: "martech/martech-data-quality.md".into() },
        AuditPrompt { id: "website-security".into(), name: "Website Security".into(), category: "Security".into(), description: "SSL/TLS, security headers, CMS vulnerabilities, cookie flags".into(), filename: "security/website-security.md".into() },
        AuditPrompt { id: "system-security".into(), name: "System Security".into(), category: "Security".into(), description: "Users, permissions, firewall, SSH, encryption, patching".into(), filename: "security/system-security.md".into() },
        AuditPrompt { id: "email-dns".into(), name: "Email & DNS Audit".into(), category: "Email & DNS".into(), description: "SPF, DKIM, DMARC, MX records, DNS security".into(), filename: "email-dns/email-dns-audit.md".into() },
        AuditPrompt { id: "gdpr-privacy".into(), name: "GDPR & Privacy".into(), category: "Privacy".into(), description: "Cookie consent, privacy policy, data collection compliance".into(), filename: "privacy/gdpr-privacy-audit.md".into() },
        AuditPrompt { id: "social-media".into(), name: "Social Media & Structured Data".into(), category: "Social".into(), description: "Open Graph, Twitter Cards, Schema.org markup".into(), filename: "social/social-media-audit.md".into() },
        AuditPrompt { id: "api-security".into(), name: "API Security".into(), category: "API".into(), description: "Endpoints, auth, CORS, rate limiting, error handling".into(), filename: "api/api-security-audit.md".into() },
    ]
}

#[tauri::command]
fn get_config() -> PrismoConfig {
    PrismoConfig {
        version: "1.0.0".into(),
        language: "en".into(),
        default_report_format: "markdown".into(),
        branding: BrandingConfig {
            agency: "diShine Digital Agency".into(),
            website: "https://dishine.it".into(),
        },
        client: ClientProfile {
            name: String::new(),
            domain: String::new(),
            industry: String::new(),
            notes: String::new(),
        },
    }
}

#[tauri::command]
fn save_config(config: PrismoConfig) -> Result<(), String> {
    let json = serde_json::to_string_pretty(&config).map_err(|e| e.to_string())?;
    fs::write("prismo.config.json", json).map_err(|e| e.to_string())?;
    Ok(())
}

#[tauri::command]
fn list_reports(reports_dir: String) -> Vec<ReportMeta> {
    let path = PathBuf::from(&reports_dir);
    let mut reports = Vec::new();

    if let Ok(entries) = fs::read_dir(&path) {
        for entry in entries.flatten() {
            let file_path = entry.path();
            if file_path.extension().and_then(|e| e.to_str()) == Some("md") {
                if let Ok(metadata) = fs::metadata(&file_path) {
                    let filename = file_path.file_name()
                        .and_then(|n| n.to_str())
                        .unwrap_or("unknown")
                        .to_string();

                    let title = filename
                        .trim_end_matches(".md")
                        .replace('-', " ")
                        .replace('_', " ");

                    let date = metadata.modified()
                        .map(|t| {
                            let datetime: chrono::DateTime<chrono::Utc> = t.into();
                            datetime.format("%Y-%m-%d %H:%M").to_string()
                        })
                        .unwrap_or_else(|_| "Unknown".into());

                    reports.push(ReportMeta {
                        filename,
                        title,
                        date,
                        size: metadata.len(),
                    });
                }
            }
        }
    }

    reports.sort_by(|a, b| b.date.cmp(&a.date));
    reports
}

#[tauri::command]
fn read_report(filepath: String) -> Result<String, String> {
    fs::read_to_string(&filepath).map_err(|e| format!("Failed to read report: {}", e))
}

#[tauri::command]
fn save_report(filepath: String, content: String) -> Result<(), String> {
    if let Some(parent) = PathBuf::from(&filepath).parent() {
        fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    fs::write(&filepath, &content).map_err(|e| format!("Failed to save report: {}", e))
}

#[tauri::command]
fn get_system_info() -> serde_json::Value {
    serde_json::json!({
        "os": std::env::consts::OS,
        "arch": std::env::consts::ARCH,
        "family": std::env::consts::FAMILY,
    })
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_fs::init())
        .invoke_handler(tauri::generate_handler![
            get_audit_prompts,
            get_config,
            save_config,
            list_reports,
            read_report,
            save_report,
            get_system_info,
        ])
        .run(tauri::generate_context!())
        .expect("error while running Prismo");
}
