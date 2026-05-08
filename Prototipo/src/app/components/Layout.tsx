import { Outlet, useNavigate, useLocation } from "react-router";
import { Sidebar } from "./Sidebar";
import { useAuth } from "../context/AuthContext";
import { useEffect } from "react";

export function Layout() {
  const { currentUser } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    // Redirigir al login si no hay usuario autenticado
    if (!currentUser) {
      navigate("/login", { replace: true });
      return;
    }

    // Redirigir alumnos al buscador si intentan acceder a rutas administrativas
    if (currentUser.role === "Student") {
      const path = location.pathname;
      
      // Permitir rutas de estudiantes y vistas de detalles
      if (path.startsWith("/student/")) {
        return;
      }
      
      // Permitir ver detalles de libros (pero no crear/editar)
      if (path.startsWith("/books/") && !path.includes("/edit") && !path.includes("/create")) {
        return;
      }
      
      // Permitir ver detalles de copias (pero no crear)
      if (path.startsWith("/copies/") && !path.includes("/create")) {
        return;
      }
      
      // Redirigir cualquier otra ruta
      navigate("/student/search", { replace: true });
    }
  }, [currentUser, location.pathname, navigate]);

  if (!currentUser) {
    return null;
  }

  return (
    <div className="flex min-h-screen bg-[var(--background-gray)]">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}