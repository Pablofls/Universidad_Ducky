import { useState } from "react";
import { useNavigate } from "react-router";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Input } from "../../components/ui/Input";
import { Select } from "../../components/ui/Select";
import { Alert } from "../../components/ui/Alert";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";
import { Download, Loader2, CheckCircle } from "lucide-react";

// Mock data para simular importación desde base de datos externa
const mockExternalDatabase: Record<string, { name: string; email: string; role: string }> = {
  // Estudiantes
  "STU2024001": { name: "Carlos Hernández", email: "carlos.hernandez@ducky.edu", role: "Student" },
  "STU2024002": { name: "Ana María López", email: "ana.lopez@ducky.edu", role: "Student" },
  "STU2024003": { name: "Luis Fernando García", email: "luis.garcia@ducky.edu", role: "Student" },
  // Profesores
  "PRO2023001": { name: "Dr. Roberto Martínez", email: "r.martinez@ducky.edu", role: "Professor" },
  "PRO2023002": { name: "Dra. Patricia Ruiz", email: "p.ruiz@ducky.edu", role: "Professor" },
  // Bibliotecarios
  "LIB2022001": { name: "Juan Carlos Pérez", email: "jc.perez@ducky.edu", role: "Librarian" },
  "LIB2022002": { name: "María Fernanda Torres", email: "mf.torres@ducky.edu", role: "Librarian" },
  // Administradores
  "ADM2021001": { name: "Patricia Gómez", email: "p.gomez@ducky.edu", role: "Administrator" },
  "ADM2021002": { name: "Roberto Sánchez", email: "r.sanchez@ducky.edu", role: "Administrator" },
};

export function CreateUser() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    id: "",
    name: "",
    email: "",
    role: "",
    status: "Active",
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [showSuccess, setShowSuccess] = useState(false);
  const [isImporting, setIsImporting] = useState(false);
  const [isImported, setIsImported] = useState(false);

  const handleImport = async () => {
    if (!formData.id.trim()) {
      setErrors({ id: "Por favor ingresa una Matrícula o ID de Empleado" });
      return;
    }

    setIsImporting(true);
    setErrors({});

    // Simular llamada a API externa
    setTimeout(() => {
      const externalData = mockExternalDatabase[formData.id];

      if (externalData) {
        setFormData({
          ...formData,
          name: externalData.name,
          email: externalData.email,
          role: externalData.role,
        });
        setIsImported(true);
        setErrors({});
      } else {
        setErrors({ 
          id: "No se encontró información para este ID. Verifica que sea correcto." 
        });
        setIsImported(false);
      }

      setIsImporting(false);
    }, 1500);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation
    const newErrors: Record<string, string> = {};
    
    if (!formData.id.trim()) {
      newErrors.id = "La Matrícula o ID de Empleado es requerido";
    }
    if (!isImported) {
      newErrors.id = "Debes importar los datos del usuario antes de guardar";
      setErrors(newErrors);
      return;
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    // Simulate save
    setShowSuccess(true);
    setTimeout(() => {
      navigate("/users");
    }, 1500);
  };

  const handleChange = (field: string, value: string) => {
    setFormData({ ...formData, [field]: value });
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors({ ...errors, [field]: "" });
    }
    // Reset imported status if ID changes
    if (field === "id" && isImported) {
      setIsImported(false);
      setFormData({
        id: value,
        name: "",
        email: "",
        role: "",
        status: "Active",
      });
    }
  };

  const getRoleLabel = (role: string) => {
    switch (role) {
      case "Student":
        return "Estudiante";
      case "Professor":
        return "Profesor";
      case "Librarian":
        return "Bibliotecario";
      case "Administrator":
        return "Administrador";
      default:
        return role;
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: "Usuarios", href: "/users" },
            { label: "Crear Usuario" },
          ]}
        />
        <h1 className="text-gray-900 mt-4">Crear Nuevo Usuario</h1>
        <p className="text-gray-600 mt-1">Importar usuario desde la base de datos externa</p>
      </div>

      {/* Success Alert */}
      {showSuccess && (
        <Alert variant="success">
          Usuario creado exitosamente! Redirigiendo...
        </Alert>
      )}

      {/* Info Alert */}
      {!isImported && (
        <Alert variant="info">
          Los datos del usuario se importarán automáticamente desde la base de datos externa. 
          Ingresa la Matrícula o ID de Empleado y haz clic en "Importar Datos".
        </Alert>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit}>
        <Card>
          <CardHeader>
            <h3>Información del Usuario</h3>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* ID and Import Button */}
            <div>
              <div className="flex gap-3">
                <div className="flex-1">
                  <Input
                    label="Matrícula / ID de Empleado"
                    placeholder="ej., STU2024001, PRO2023001, LIB2022001, ADM2021001"
                    value={formData.id}
                    onChange={(e) => handleChange("id", e.target.value)}
                    error={errors.id}
                    required
                    disabled={isImporting}
                  />
                </div>
                <div className="flex items-end">
                  <Button
                    type="button"
                    variant="primary"
                    onClick={handleImport}
                    disabled={isImporting || !formData.id.trim()}
                    className="whitespace-nowrap"
                  >
                    {isImporting ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        Importando...
                      </>
                    ) : (
                      <>
                        <Download className="h-4 w-4" />
                        Importar Datos
                      </>
                    )}
                  </Button>
                </div>
              </div>
              {isImported && (
                <p className="text-sm text-green-600 mt-2 flex items-center gap-1">
                  <CheckCircle className="h-4 w-4" />
                  Datos importados exitosamente
                </p>
              )}
            </div>

            {/* Imported Data Section */}
            {isImported && (
              <>
                <div className="border-t border-gray-200 pt-6 space-y-6">
                  <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                    <p className="text-sm text-green-800 font-medium">
                      Datos Importados de la Base de Datos Externa
                    </p>
                    <p className="text-xs text-green-600 mt-1">
                      Verifica que la información sea correcta antes de guardar
                    </p>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <Input
                      label="Nombre Completo"
                      value={formData.name}
                      disabled
                      readOnly
                    />

                    <Input
                      label="Tipo de Usuario"
                      value={getRoleLabel(formData.role)}
                      disabled
                      readOnly
                    />
                  </div>

                  <Input
                    label="Correo Electrónico"
                    type="email"
                    value={formData.email}
                    disabled
                    readOnly
                  />

                  <Select
                    label="Estado de la Cuenta"
                    value={formData.status}
                    onChange={(e) => handleChange("status", e.target.value)}
                    required
                  >
                    <option value="Active">Activo</option>
                    <option value="Inactive">Inactivo</option>
                    <option value="Suspended">Suspendido</option>
                  </Select>
                </div>
              </>
            )}
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex justify-end gap-3 mt-6">
          <Button type="button" variant="ghost" onClick={() => navigate("/users")}>
            Cancelar
          </Button>
          <Button 
            type="submit" 
            variant="primary"
            disabled={!isImported}
          >
            Guardar Usuario
          </Button>
        </div>
      </form>

      {/* Helper Card */}
      <Card>
        <CardHeader>
          <h3>IDs de Ejemplo para Pruebas</h3>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-sm">
            <div>
              <p className="font-medium text-gray-900 mb-2">Estudiantes:</p>
              <ul className="space-y-1 text-gray-600">
                <li>• STU2024001</li>
                <li>• STU2024002</li>
                <li>• STU2024003</li>
              </ul>
            </div>
            <div>
              <p className="font-medium text-gray-900 mb-2">Profesores:</p>
              <ul className="space-y-1 text-gray-600">
                <li>• PRO2023001</li>
                <li>• PRO2023002</li>
              </ul>
            </div>
            <div>
              <p className="font-medium text-gray-900 mb-2">Bibliotecarios:</p>
              <ul className="space-y-1 text-gray-600">
                <li>• LIB2022001</li>
                <li>• LIB2022002</li>
              </ul>
            </div>
            <div>
              <p className="font-medium text-gray-900 mb-2">Administradores:</p>
              <ul className="space-y-1 text-gray-600">
                <li>• ADM2021001</li>
                <li>• ADM2021002</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}