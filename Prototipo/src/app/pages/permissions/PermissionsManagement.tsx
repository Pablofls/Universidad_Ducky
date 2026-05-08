import { useState } from "react";
import { Shield, Save, RotateCcw, Info } from "lucide-react";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";
import { Alert } from "../../components/ui/Alert";

// Define los permisos disponibles en el sistema
const permissions = [
  {
    category: "Gestión de Usuarios",
    items: [
      { id: "users.view", name: "Ver usuarios", description: "Ver lista y detalles de usuarios" },
      { id: "users.create", name: "Crear usuarios", description: "Crear nuevos usuarios en el sistema" },
      { id: "users.delete", name: "Eliminar usuarios", description: "Eliminar usuarios del sistema" },
    ],
  },
  {
    category: "Gestión de Catálogo",
    items: [
      { id: "books.view", name: "Ver libros", description: "Ver catálogo de libros" },
      { id: "books.create", name: "Crear libros", description: "Agregar nuevos libros al catálogo" },
      { id: "books.edit", name: "Editar libros", description: "Modificar información de libros" },
      { id: "books.delete", name: "Eliminar libros", description: "Eliminar libros del catálogo" },
    ],
  },
  {
    category: "Gestión de Ejemplares",
    items: [
      { id: "copies.view", name: "Ver ejemplares", description: "Ver inventario de ejemplares" },
      { id: "copies.create", name: "Crear ejemplares", description: "Agregar nuevos ejemplares" },
      { id: "copies.edit", name: "Editar ejemplares", description: "Modificar información de ejemplares" },
      { id: "copies.delete", name: "Eliminar ejemplares", description: "Eliminar ejemplares del inventario" },
    ],
  },
  {
    category: "Solicitudes de Compra",
    items: [
      { id: "purchases.view", name: "Ver solicitudes", description: "Ver solicitudes de compra" },
      { id: "purchases.create", name: "Crear solicitudes", description: "Crear nuevas solicitudes de compra" },
      { id: "purchases.approve", name: "Aprobar solicitudes", description: "Aprobar o rechazar solicitudes" },
      { id: "purchases.delete", name: "Eliminar solicitudes", description: "Eliminar solicitudes de compra" },
    ],
  },
  {
    category: "Búsqueda de Libros",
    items: [
      { id: "search.books", name: "Buscar libros", description: "Buscar y ver disponibilidad de libros" },
      { id: "search.advanced", name: "Búsqueda avanzada", description: "Usar filtros avanzados de búsqueda" },
    ],
  },
  {
    category: "Reportes y Analíticas",
    items: [
      { id: "reports.view", name: "Ver reportes", description: "Acceso a reportes y estadísticas" },
      { id: "reports.export", name: "Exportar reportes", description: "Exportar datos en formato CSV/PDF" },
    ],
  },
  {
    category: "Configuración del Sistema",
    items: [
      { id: "system.permissions", name: "Gestionar permisos", description: "Configurar permisos de roles" },
      { id: "system.settings", name: "Configuración general", description: "Modificar configuración del sistema" },
    ],
  },
];

// Permisos por defecto para cada rol
const defaultRolePermissions: Record<string, string[]> = {
  Student: [
    "search.books",
    "search.advanced",
  ],
  Professor: [
    "search.books",
    "search.advanced",
    "purchases.view",
    "purchases.create",
    "books.view",
    "copies.view",
  ],
  Librarian: [
    "users.view",
    "users.create",
    "users.delete",
    "books.view",
    "books.create",
    "books.edit",
    "books.delete",
    "copies.view",
    "copies.create",
    "copies.edit",
    "copies.delete",
    "purchases.view",
    "purchases.create",
    "purchases.approve",
    "purchases.delete",
    "search.books",
    "search.advanced",
    "reports.view",
    "reports.export",
  ],
  Administrator: [
    "users.view",
    "users.create",
    "users.delete",
    "books.view",
    "books.create",
    "books.edit",
    "books.delete",
    "copies.view",
    "copies.create",
    "copies.edit",
    "copies.delete",
    "purchases.view",
    "purchases.create",
    "purchases.approve",
    "purchases.delete",
    "search.books",
    "search.advanced",
    "reports.view",
    "reports.export",
    "system.permissions",
    "system.settings",
  ],
};

const roleLabels: Record<string, string> = {
  Student: "Estudiante",
  Professor: "Profesor",
  Librarian: "Bibliotecario",
  Administrator: "Administrador",
};

export function PermissionsManagement() {
  const [selectedRole, setSelectedRole] = useState<string>("Student");
  const [rolePermissions, setRolePermissions] = useState<Record<string, string[]>>(defaultRolePermissions);
  const [showSuccess, setShowSuccess] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  const currentPermissions = rolePermissions[selectedRole] || [];

  const hasPermission = (permissionId: string) => {
    return currentPermissions.includes(permissionId);
  };

  const togglePermission = (permissionId: string) => {
    const updated = hasPermission(permissionId)
      ? currentPermissions.filter((p) => p !== permissionId)
      : [...currentPermissions, permissionId];

    setRolePermissions({
      ...rolePermissions,
      [selectedRole]: updated,
    });
    setHasChanges(true);
  };

  const handleSave = () => {
    // Simulate save
    setShowSuccess(true);
    setHasChanges(false);
    setTimeout(() => setShowSuccess(false), 3000);
  };

  const handleReset = () => {
    setRolePermissions(defaultRolePermissions);
    setHasChanges(false);
  };

  const getPermissionCount = (role: string) => {
    return (rolePermissions[role] || []).length;
  };

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb items={[{ label: "Permisos" }]} />
        <div className="flex items-center justify-between mt-4">
          <div>
            <h1 className="text-gray-900">Gestión de Permisos</h1>
            <p className="text-gray-600 mt-1">Configurar permisos por rol de usuario</p>
          </div>
          <div className="flex gap-3">
            <Button variant="ghost" onClick={handleReset} disabled={!hasChanges}>
              <RotateCcw className="h-5 w-5" />
              Restablecer
            </Button>
            <Button onClick={handleSave} disabled={!hasChanges}>
              <Save className="h-5 w-5" />
              Guardar Cambios
            </Button>
          </div>
        </div>
      </div>

      {/* Success Alert */}
      {showSuccess && (
        <Alert variant="success">
          Los permisos se han guardado exitosamente!
        </Alert>
      )}

      {/* Info Alert */}
      {hasChanges && (
        <Alert variant="warning">
          Tienes cambios sin guardar. Haz clic en "Guardar Cambios" para aplicarlos.
        </Alert>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Role Selection */}
        <div className="lg:col-span-1 space-y-4">
          <Card>
            <CardHeader>
              <h3 className="flex items-center gap-2">
                <Shield className="h-5 w-5 text-[var(--primary)]" />
                Roles
              </h3>
            </CardHeader>
            <CardContent className="space-y-2">
              {Object.keys(roleLabels).map((role) => (
                <button
                  key={role}
                  onClick={() => setSelectedRole(role)}
                  className={`w-full px-4 py-3 rounded-lg text-left transition-colors ${
                    selectedRole === role
                      ? "bg-[var(--primary)] text-white"
                      : "bg-gray-50 hover:bg-gray-100 text-gray-700"
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className="font-medium">{roleLabels[role]}</span>
                    <span
                      className={`text-xs px-2 py-1 rounded-full ${
                        selectedRole === role
                          ? "bg-white/20 text-white"
                          : "bg-gray-200 text-gray-600"
                      }`}
                    >
                      {getPermissionCount(role)}
                    </span>
                  </div>
                </button>
              ))}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <h3 className="flex items-center gap-2">
                <Info className="h-5 w-5 text-blue-600" />
                Información
              </h3>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-gray-600">
                Los permisos determinan qué acciones puede realizar cada rol en el sistema.
                Selecciona un rol para ver y modificar sus permisos.
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Permissions Grid */}
        <div className="lg:col-span-3 space-y-6">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3>Permisos para {roleLabels[selectedRole]}</h3>
                <span className="text-sm text-gray-500">
                  {currentPermissions.length} permisos activos
                </span>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              {permissions.map((category) => (
                <div key={category.category}>
                  <h4 className="text-gray-900 mb-3">{category.category}</h4>
                  <div className="space-y-2">
                    {category.items.map((permission) => (
                      <label
                        key={permission.id}
                        className="flex items-start gap-3 p-3 rounded-lg hover:bg-gray-50 cursor-pointer transition-colors"
                      >
                        <input
                          type="checkbox"
                          checked={hasPermission(permission.id)}
                          onChange={() => togglePermission(permission.id)}
                          className="mt-1 h-4 w-4 rounded border-gray-300 text-[var(--primary)] focus:ring-[var(--primary)]"
                        />
                        <div className="flex-1">
                          <p className="text-sm font-medium text-gray-900">
                            {permission.name}
                          </p>
                          <p className="text-xs text-gray-500 mt-0.5">
                            {permission.description}
                          </p>
                        </div>
                      </label>
                    ))}
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
