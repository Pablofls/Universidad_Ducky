import { useState } from "react";
import { useNavigate } from "react-router";
import { Search, DollarSign, Eye, CheckCircle } from "lucide-react";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { Badge } from "../../components/ui/badge";
import { mockFines } from "../../data/loans";
import { FineStatus } from "../../types";

export function Fines() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<FineStatus | "All">("All");

  const filteredFines = mockFines.filter((fine) => {
    const matchesSearch =
      fine.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      fine.userId.toLowerCase().includes(searchQuery.toLowerCase()) ||
      fine.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      fine.bookTitle.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesStatus = statusFilter === "All" || fine.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: FineStatus) => {
    switch (status) {
      case "Pending":
        return <Badge variant="warning">Pendiente</Badge>;
      case "Paid":
        return <Badge variant="success">Pagado</Badge>;
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  const totalPending = mockFines
    .filter((fine) => fine.status === "Pending")
    .reduce((sum, fine) => sum + fine.amount, 0);

  const totalPaid = mockFines
    .filter((fine) => fine.status === "Paid")
    .reduce((sum, fine) => sum + fine.amount, 0);

  const handleMarkAsPaid = (fineId: string) => {
    alert(`Multa ${fineId} marcada como pagada`);
  };

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="mb-2">Gestión de Multas</h1>
        <p className="text-gray-600">Administra las multas por devoluciones tardías</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-gray-600">Multas Pendientes</span>
            <DollarSign className="h-5 w-5 text-orange-500" />
          </div>
          <p className="text-3xl font-bold text-gray-900">${totalPending}</p>
          <p className="text-sm text-gray-500 mt-1">
            {mockFines.filter((f) => f.status === "Pending").length} multas
          </p>
        </div>

        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-gray-600">Multas Pagadas</span>
            <CheckCircle className="h-5 w-5 text-green-500" />
          </div>
          <p className="text-3xl font-bold text-gray-900">${totalPaid}</p>
          <p className="text-sm text-gray-500 mt-1">
            {mockFines.filter((f) => f.status === "Paid").length} multas
          </p>
        </div>

        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-2">
            <span className="text-gray-600">Total Recaudado</span>
            <DollarSign className="h-5 w-5 text-[var(--primary)]" />
          </div>
          <p className="text-3xl font-bold text-gray-900">${totalPaid}</p>
          <p className="text-sm text-gray-500 mt-1">Este mes</p>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Search */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Buscar
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
              <Input
                type="text"
                placeholder="ID, Usuario, Libro..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          {/* Status Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Estado
            </label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as FineStatus | "All")}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--primary)] focus:border-transparent"
            >
              <option value="All">Todos los estados</option>
              <option value="Pending">Pendiente</option>
              <option value="Paid">Pagado</option>
            </select>
          </div>
        </div>
      </div>

      {/* Results Count */}
      <div className="mb-4">
        <p className="text-gray-600">
          Mostrando {filteredFines.length} de {mockFines.length} multas
        </p>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  ID Multa
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Usuario
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Libro
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Días de Retraso
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Monto
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Fecha Creación
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Estado
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredFines.map((fine) => (
                <tr key={fine.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm font-medium text-gray-900">{fine.id}</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">
                        {fine.userName}
                      </div>
                      <div className="text-sm text-gray-500">{fine.userId}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-sm text-gray-900">{fine.bookTitle}</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm text-gray-900">{fine.daysOverdue} días</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm font-medium text-gray-900">
                      ${fine.amount}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="text-sm text-gray-600">
                      {formatDate(fine.createdAt)}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {getStatusBadge(fine.status)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => navigate(`/loans/${fine.loanId}`)}
                        title="Ver préstamo relacionado"
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                      {fine.status === "Pending" && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleMarkAsPaid(fine.id)}
                          title="Marcar como pagado"
                        >
                          <CheckCircle className="h-4 w-4 text-green-600" />
                        </Button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredFines.length === 0 && (
          <div className="text-center py-12">
            <DollarSign className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">No se encontraron multas</p>
          </div>
        )}
      </div>
    </div>
  );
}