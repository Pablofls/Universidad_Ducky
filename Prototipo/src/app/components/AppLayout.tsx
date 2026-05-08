import { Outlet, useNavigate } from "react-router";
import { useAuth } from "../context/AuthContext";
import { useEffect, useState } from "react";
import { LogOut, Menu, X } from "lucide-react";
import duckyLogo from "figma:asset/8bcd95b2cd93ddde6339a2d9cc09c302324238c7.png";

export function AppLayout() {
  const { currentUser, logout } = useAuth();
  const navigate = useNavigate();
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  useEffect(() => {
    // Redirigir al login si no hay usuario autenticado
    if (!currentUser) {
      navigate("/login", { replace: true });
    }
  }, [currentUser, navigate]);

  if (!currentUser) {
    return null;
  }

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
    <div className="min-h-screen bg-[var(--background-gray)]">
      {/* Mobile Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-40 shadow-sm">
        <div className="flex items-center justify-between px-4 py-4">
          <div className="flex items-center gap-3">
            <img 
              src={duckyLogo} 
              alt="Logo Universidad Ducky" 
              className="w-10 h-10 object-contain"
            />
            <div>
              <h1 className="text-lg font-bold text-gray-900">Ducky</h1>
              <p className="text-xs text-gray-500">App Móvil</p>
            </div>
          </div>
          <button
            onClick={() => setIsMenuOpen(true)}
            className="p-2.5 hover:bg-gray-100 rounded-lg transition-colors active:bg-gray-200"
          >
            <Menu className="h-6 w-6 text-gray-700" />
          </button>
        </div>
      </div>

      {/* Main content */}
      <main className="pb-4">
        <Outlet />
      </main>

      {/* Mobile Menu Drawer */}
      {isMenuOpen && (
        <>
          {/* Drawer */}
          <div className="fixed inset-0 bg-white z-50">
            <div className="flex flex-col h-full">
              {/* Header */}
              <div className="flex items-center justify-between p-4 border-b border-gray-200">
                <h2 className="font-semibold text-gray-900">Mi Cuenta</h2>
                <button
                  onClick={() => setIsMenuOpen(false)}
                  className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  <X className="h-5 w-5 text-gray-700" />
                </button>
              </div>

              {/* User Info */}
              <div className="p-4 border-b border-gray-200">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-12 h-12 bg-[var(--primary)] bg-opacity-10 rounded-full flex items-center justify-center">
                    <span className="text-[var(--primary)] font-semibold">{getUserInitials()}</span>
                  </div>
                  <div className="flex-1">
                    <p className="font-medium text-gray-900">{currentUser.name}</p>
                    <p className="text-sm text-gray-500">{getRoleLabel()}</p>
                    <p className="text-xs text-gray-400">{currentUser.email}</p>
                  </div>
                </div>
              </div>

              {/* Spacer */}
              <div className="flex-1"></div>

              {/* Logout Button */}
              <div className="p-4 border-t border-gray-200">
                <button
                  onClick={handleLogout}
                  className="w-full flex items-center justify-center gap-2 px-4 py-3 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg transition-colors border border-red-200"
                >
                  <LogOut className="h-5 w-5" />
                  Cerrar Sesión
                </button>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}