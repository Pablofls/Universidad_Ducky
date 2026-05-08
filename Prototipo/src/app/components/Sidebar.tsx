import { NavLink, useNavigate } from "react-router";
import { LayoutDashboard, Users, Book, BookCopy, ShoppingCart, Search, LogOut, Shield, Calendar } from "lucide-react";
import { cn } from "../lib/utils";
import { useAuth } from "../context/AuthContext";
import duckyLogo from "figma:asset/8bcd95b2cd93ddde6339a2d9cc09c302324238c7.png";

const adminNavigation = [
  { name: "Tablero", href: "/", icon: LayoutDashboard, roles: ["Administrator", "Librarian"] },
  { name: "Usuarios", href: "/users", icon: Users, roles: ["Administrator", "Librarian"] },
  { name: "Libros", href: "/books", icon: Book, roles: ["Administrator", "Librarian"] },
  { name: "Ejemplares", href: "/copies", icon: BookCopy, roles: ["Administrator", "Librarian"] },
  { name: "Préstamos", href: "/loans", icon: Calendar, roles: ["Administrator", "Librarian"] },
  { name: "Solicitudes de Compra", href: "/purchases", icon: ShoppingCart, roles: ["Administrator", "Librarian"] },
  { name: "Permisos", href: "/permissions", icon: Shield, roles: ["Administrator"] },
];

const studentNavigation = [
  { name: "Buscar Libros", href: "/student/search", icon: Search, roles: ["Student"] },
];

export function Sidebar() {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();

  if (!currentUser) return null;

  const isStudent = currentUser.role === "Student";
  const navigation = isStudent 
    ? studentNavigation 
    : adminNavigation.filter(item => item.roles.includes(currentUser.role));

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  const getUserInitials = () => {
    return currentUser.name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .substring(0, 2);
  };

  const getRoleLabel = () => {
    switch (currentUser.role) {
      case "Administrator":
        return "Administrador";
      case "Student":
        return "Alumno";
      case "Professor":
        return "Profesor";
      case "Librarian":
        return "Bibliotecario";
      default:
        return currentUser.role;
    }
  };

  return (
    <div className="w-64 bg-white border-r border-gray-200 flex flex-col h-screen sticky top-0">
      {/* Logo */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center gap-3">
          <img 
            src={duckyLogo} 
            alt="Logo Universidad Ducky" 
            className="w-10 h-10 object-contain"
          />
          <div>
            <h1 className="font-semibold text-gray-900">Ducky</h1>
            <p className="text-xs text-gray-500">Sistema de Gestión</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1">
        {navigation.map((item) => (
          <NavLink
            key={item.name}
            to={item.href}
            end={item.href === "/"}
            className={({ isActive }) =>
              cn(
                "flex items-center gap-3 px-4 py-3 rounded-lg transition-colors",
                isActive
                  ? "bg-[var(--primary)] text-white"
                  : "text-gray-700 hover:bg-gray-100"
              )
            }
          >
            <item.icon className="h-5 w-5" />
            <span>{item.name}</span>
          </NavLink>
        ))}
      </nav>

      {/* User Info */}
      <div className="p-4 border-t border-gray-200 space-y-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
            <span className="text-gray-600 font-medium">{getUserInitials()}</span>
          </div>
          <div className="flex-1">
            <p className="text-sm font-medium text-gray-900">{currentUser.name}</p>
            <p className="text-xs text-gray-500">{getRoleLabel()}</p>
          </div>
        </div>
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors border border-red-200"
        >
          <LogOut className="h-4 w-4" />
          Cerrar Sesión
        </button>
      </div>
    </div>
  );
}