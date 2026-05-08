import { useNavigate } from "react-router";
import { Home, ArrowLeft } from "lucide-react";
import { Button } from "../components/ui/Button";
import { useAuth } from "../context/AuthContext";

export function NotFound() {
  const navigate = useNavigate();
  const { currentUser } = useAuth();

  const handleGoHome = () => {
    if (!currentUser) {
      navigate("/login");
    } else if (currentUser.role === "Student") {
      navigate("/student/search");
    } else {
      navigate("/");
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="text-center">
        <h1 className="text-gray-900 mb-4">404</h1>
        <h2 className="font-semibold text-gray-900 mb-2">Página no encontrada</h2>
        <p className="text-gray-600 mb-8">
          La página que estás buscando no existe o ha sido movida.
        </p>
        <div className="flex gap-3 justify-center">
          <Button variant="ghost" onClick={() => navigate(-1)}>
            <ArrowLeft className="h-5 w-5" />
            Volver
          </Button>
          <Button onClick={handleGoHome}>
            <Home className="h-5 w-5" />
            Ir al Inicio
          </Button>
        </div>
      </div>
    </div>
  );
}
