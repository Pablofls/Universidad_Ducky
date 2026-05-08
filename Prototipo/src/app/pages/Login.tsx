import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { LogIn, Monitor, Smartphone } from "lucide-react";
import { useAuth } from "../context/AuthContext";
import { Button } from "../components/ui/Button";
import { Input } from "../components/ui/Input";
import duckyLogo from "figma:asset/8bcd95b2cd93ddde6339a2d9cc09c302324238c7.png";

const availableUsers = [
  {
    id: "admin-001",
    name: "Usuario Admin",
    role: "Administrator" as const,
    email: "admin@ducky.edu",
    password: "admin",
  },
  {
    id: "student-001",
    name: "Alumno",
    role: "Student" as const,
    email: "alumno@ducky.edu",
    password: "alumno",
  },
];

type LoginVersion = "web" | "app" | null;

export function Login() {
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [error, setError] = useState<string>("");
  const [selectedVersion, setSelectedVersion] = useState<LoginVersion>(null);
  const { login, currentUser } = useAuth();
  const navigate = useNavigate();

  // Si ya hay usuario autenticado, redirigir
  useEffect(() => {
    if (currentUser) {
      if (currentUser.role === "Student") {
        navigate("/student/search", { replace: true });
      } else {
        navigate("/", { replace: true });
      }
    }
  }, [currentUser, navigate]);

  // No renderizar el formulario si ya hay un usuario autenticado
  if (currentUser) {
    return null;
  }

  const handleLogin = (version: LoginVersion) => {
    setError("");
    const user = availableUsers.find((u) => u.email === email && u.password === password);
    if (user) {
      login(user);
      // Redirigir según la versión seleccionada
      if (version === "app") {
        navigate("/app", { replace: true });
      } else if (user.role === "Student") {
        navigate("/student/search", { replace: true });
      } else {
        navigate("/", { replace: true });
      }
    } else {
      setError("Correo electrónico o contraseña incorrectos");
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && email && password && selectedVersion) {
      handleLogin(selectedVersion);
    }
  };

  return (
    <div
      className="min-h-screen bg-gradient-to-br from-[var(--primary)] to-green-700 flex items-center justify-center p-4"
      onKeyPress={handleKeyPress}
    >
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <img
            src={duckyLogo}
            alt="Universidad Ducky Logo"
            className="h-32 w-32 mx-auto mb-4"
          />
          <h1 className="text-white mb-2">Sistema de Gestión Ducky</h1>
          <p className="text-white/80">Universidad Ducky</p>
        </div>

        {/* Login Card */}
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <div className="mb-6">
            <h2 className="font-semibold text-gray-900 mb-2">Iniciar Sesión</h2>
            <p className="text-gray-600">Selecciona la plataforma e ingresa tus credenciales</p>
          </div>

          {/* Version Selection */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-3">
              Selecciona la Plataforma
            </label>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setSelectedVersion("web")}
                className={`flex flex-col items-center gap-2 p-4 border-2 rounded-lg transition-all relative ${
                  selectedVersion === "web"
                    ? "border-[var(--primary)] bg-[var(--primary)] bg-opacity-40"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <Monitor className={`h-8 w-8 relative z-10 ${selectedVersion === "web" ? "text-white" : "text-gray-400"}`} />
                <span className={`text-sm font-medium relative z-10 ${selectedVersion === "web" ? "text-white" : "text-gray-700"}`}>
                  Versión Web
                </span>
              </button>
              <button
                onClick={() => setSelectedVersion("app")}
                className={`flex flex-col items-center gap-2 p-4 border-2 rounded-lg transition-all relative ${
                  selectedVersion === "app"
                    ? "border-[var(--primary)] bg-[var(--primary)] bg-opacity-40"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <Smartphone className={`h-8 w-8 relative z-10 ${selectedVersion === "app" ? "text-white" : "text-gray-400"}`} />
                <span className={`text-sm font-medium relative z-10 ${selectedVersion === "app" ? "text-white" : "text-gray-700"}`}>
                  Versión App
                </span>
              </button>
            </div>
            {selectedVersion && (
              <p className="text-xs text-gray-500 mt-2">
                {selectedVersion === "web" 
                  ? "Acceso completo con funciones administrativas según tu rol" 
                  : "Solo búsqueda de libros disponible para todos los usuarios"}
              </p>
            )}
          </div>

          <div className="space-y-4 mb-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Correo Electrónico
              </label>
              <Input
                type="email"
                placeholder="ejemplo@ducky.edu"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  setError("");
                }}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Contraseña
              </label>
              <Input
                type="password"
                placeholder="Ingresa tu contraseña"
                value={password}
                onChange={(e) => {
                  setPassword(e.target.value);
                  setError("");
                }}
              />
            </div>
          </div>

          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          <Button
            onClick={() => handleLogin(selectedVersion)}
            disabled={!email || !password || !selectedVersion}
            className="w-full justify-center"
          >
            <LogIn className="h-5 w-5" />
            Iniciar Sesión
          </Button>

          <div className="mt-6 pt-6 border-t border-gray-200">
            <p className="text-sm text-gray-500 text-center">
              Sistema de Gestión de Biblioteca v1.0
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}