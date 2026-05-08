import { useState } from "react";
import { useNavigate } from "react-router";
import { Plus, Filter, Eye } from "lucide-react";
import { mockCopies } from "../../data/mockData";
import { Copy, CopyStatus } from "../../types";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { SearchBar } from "../../components/ui/SearchBar";
import { Select } from "../../components/ui/Select";
import { StatusBadge } from "../../components/ui/StatusBadge";

export function CopyList() {
  const navigate = useNavigate();
  const [copies] = useState<Copy[]>(mockCopies);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<CopyStatus | "All">("All");

  const filteredCopies = copies.filter((copy) => {
    const matchesSearch =
      copy.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      copy.bookTitle.toLowerCase().includes(searchTerm.toLowerCase()) ||
      copy.location.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus = statusFilter === "All" || copy.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb items={[{ label: "Ejemplares" }]} />
        <div className="flex items-center justify-between mt-4">
          <div>
            <h1 className="text-gray-900">Gestión de Ejemplares</h1>
            <p className="text-gray-600 mt-1">Administrar copias físicas de libros e inventario</p>
          </div>
          <Button onClick={() => navigate("/copies/create")}>
            <Plus className="h-5 w-5" />
            Agregar Ejemplar
          </Button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg border border-gray-200">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2">
            <SearchBar
              placeholder="Buscar por ID de ejemplar, título de libro o ubicación..."
              value={searchTerm}
              onSearch={setSearchTerm}
            />
          </div>
          <div className="flex items-center gap-2">
            <Filter className="h-5 w-5 text-gray-400" />
            <Select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as CopyStatus | "All")}
            >
              <option value="All">Todos los Estados</option>
              <option value="Available">Disponible</option>
              <option value="Loaned">Prestado</option>
              <option value="Reserved">Reservado</option>
              <option value="Internal Use">Uso Interno</option>
            </Select>
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID Ejemplar
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Título del Libro
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Ubicación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Condición
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredCopies.map((copy) => (
                <tr key={copy.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {copy.id}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-900">
                    {copy.bookTitle}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <StatusBadge status={copy.status} type="copy" />
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {copy.location}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {copy.condition}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <button
                      onClick={() => navigate(`/copies/${copy.id}`)}
                      className="text-gray-600 hover:text-[var(--primary)] transition-colors"
                      title="Ver Detalles"
                    >
                      <Eye className="h-4 w-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredCopies.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">No se encontraron ejemplares</p>
          </div>
        )}
      </div>
    </div>
  );
}