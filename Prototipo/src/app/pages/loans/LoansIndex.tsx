import { NavLink, Outlet, useLocation } from "react-router";
import { Calendar, Plus, RotateCcw, DollarSign } from "lucide-react";
import { cn } from "../../lib/utils";

const loansNavigation = [
  {
    name: "Préstamos Activos",
    href: "/loans",
    icon: Calendar,
  },
  {
    name: "Nuevo Préstamo",
    href: "/loans/new",
    icon: Plus,
  },
  {
    name: "Devoluciones",
    href: "/loans/return",
    icon: RotateCcw,
  },
  {
    name: "Multas",
    href: "/loans/fines",
    icon: DollarSign,
  },
];

export function LoansIndex() {
  const location = useLocation();

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sub Navigation */}
      <div className="bg-white border-b border-gray-200">
        <div className="px-8">
          <nav className="flex gap-1 overflow-x-auto">
            {loansNavigation.map((item) => {
              const isActive =
                item.href === "/loans"
                  ? location.pathname === "/loans"
                  : location.pathname.startsWith(item.href);

              return (
                <NavLink
                  key={item.name}
                  to={item.href}
                  className={cn(
                    "flex items-center gap-2 px-4 py-4 border-b-2 transition-colors whitespace-nowrap",
                    isActive
                      ? "border-[var(--primary)] text-[var(--primary)]"
                      : "border-transparent text-gray-600 hover:text-gray-900 hover:border-gray-300"
                  )}
                >
                  <item.icon className="h-4 w-4" />
                  <span className="text-sm font-medium">{item.name}</span>
                </NavLink>
              );
            })}
          </nav>
        </div>
      </div>

      {/* Content */}
      <Outlet />
    </div>
  );
}
