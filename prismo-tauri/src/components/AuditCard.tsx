interface AuditCardProps {
  name: string;
  category: string;
  description: string;
  icon: string;
  onClick: () => void;
}

const categoryColors: Record<string, string> = {
  "System Health": "from-blue-500/20 to-blue-600/10 border-blue-500/30 hover:border-blue-400/50",
  "Web & Performance": "from-green-500/20 to-green-600/10 border-green-500/30 hover:border-green-400/50",
  "SEO": "from-amber-500/20 to-amber-600/10 border-amber-500/30 hover:border-amber-400/50",
  "MarTech & Data": "from-pink-500/20 to-pink-600/10 border-pink-500/30 hover:border-pink-400/50",
  "Security": "from-red-500/20 to-red-600/10 border-red-500/30 hover:border-red-400/50",
  "Email & DNS": "from-cyan-500/20 to-cyan-600/10 border-cyan-500/30 hover:border-cyan-400/50",
  "Privacy": "from-violet-500/20 to-violet-600/10 border-violet-500/30 hover:border-violet-400/50",
  "Social": "from-orange-500/20 to-orange-600/10 border-orange-500/30 hover:border-orange-400/50",
  "API": "from-teal-500/20 to-teal-600/10 border-teal-500/30 hover:border-teal-400/50",
};

const categoryBadgeColors: Record<string, string> = {
  "System Health": "bg-blue-500/20 text-blue-400",
  "Web & Performance": "bg-green-500/20 text-green-400",
  "SEO": "bg-amber-500/20 text-amber-400",
  "MarTech & Data": "bg-pink-500/20 text-pink-400",
  "Security": "bg-red-500/20 text-red-400",
  "Email & DNS": "bg-cyan-500/20 text-cyan-400",
  "Privacy": "bg-violet-500/20 text-violet-400",
  "Social": "bg-orange-500/20 text-orange-400",
  "API": "bg-teal-500/20 text-teal-400",
};

export default function AuditCard({ name, category, description, icon, onClick }: AuditCardProps) {
  const gradientClass = categoryColors[category] || "from-gray-500/20 to-gray-600/10 border-gray-500/30";
  const badgeClass = categoryBadgeColors[category] || "bg-gray-500/20 text-gray-400";

  return (
    <button
      onClick={onClick}
      className={`w-full text-left p-5 rounded-xl border bg-gradient-to-br ${gradientClass} transition-all duration-200 hover:scale-[1.02] hover:shadow-lg group`}
    >
      <div className="flex items-start gap-4">
        <span className="text-2xl mt-0.5 group-hover:scale-110 transition-transform">{icon}</span>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="font-semibold text-gray-100 truncate">{name}</h3>
          </div>
          <span className={`inline-block text-xs px-2 py-0.5 rounded-full ${badgeClass} mb-2`}>
            {category}
          </span>
          <p className="text-sm text-gray-400 line-clamp-2">{description}</p>
        </div>
      </div>
    </button>
  );
}
