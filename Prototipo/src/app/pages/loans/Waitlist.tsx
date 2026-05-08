import { useState } from "react";
import { Search, Bell, Trash2, Clock } from "lucide-react";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { mockWaitlist } from "../../data/loans";

export function Waitlist() {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredWaitlist = mockWaitlist.filter((entry) =>
    entry.bookTitle.toLowerCase().includes(searchQuery.toLowerCase()) ||
    entry.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    entry.userId.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  const handleNotifyUser = (entryId: string, userName: string) => {
    alert(`Notificación enviada a ${userName}`);
  };

  const handleRemoveFromWaitlist = (entryId: string) => {
    if (confirm("¿Estás seguro de eliminar esta solicitud de la lista de espera?")) {
      alert(`Solicitud ${entryId} eliminada`);
    }
  };

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="mb-2">Lista de Espera</h1>
        <p className="text-gray-600">
          Gestiona las solicitudes de libros sin copias disponibles
        </p>
      </div>

      {/* Search */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Buscar
        </label>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
          <Input
            type="text"
            placeholder="Libro, Usuario..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-gray-600">
          Mostrando {filteredWaitlist.length} de {mockWaitlist.length} solicitudes
        </p>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Posición
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Libro
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ISBN
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Usuario
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha de Solicitud
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredWaitlist.map((entry) => (
                <tr key={entry.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center justify-center w-8 h-8 bg-[var(--primary)] text-white rounded-full font-medium">
                      {entry.position}
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-sm font-medium text-gray-900">
                      {entry.bookTitle}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm text-gray-600">{entry.bookIsbn}</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">
                        {entry.userName}
                      </div>
                      <div className="text-sm text-gray-500">{entry.userId}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-2">
                      <Clock className="h-4 w-4 text-gray-400" />
                      <span className="text-sm text-gray-600">
                        {formatDate(entry.requestDate)}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-2">
                      {entry.position === 1 && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleNotifyUser(entry.id, entry.userName)}
                          title="Notificar usuario"
                        >
                          <Bell className="h-4 w-4 text-[var(--primary)]" />
                        </Button>
                      )}
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleRemoveFromWaitlist(entry.id)}
                        title="Eliminar solicitud"
                      >
                        <Trash2 className="h-4 w-4 text-red-600" />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredWaitlist.length === 0 && (
          <div className="text-center py-12">
            <Clock className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">No hay solicitudes en lista de espera</p>
          </div>
        )}
      </div>

      {/* Info Box */}
      <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex items-start gap-3">
          <Bell className="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div>
            <h3 className="text-sm font-medium text-blue-900 mb-1">
              Cómo funciona la lista de espera
            </h3>
            <p className="text-sm text-blue-700">
              Cuando un usuario solicita un libro sin copias disponibles, se agrega a la lista
              de espera. Los usuarios en primera posición pueden ser notificados cuando una
              copia esté disponible.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
