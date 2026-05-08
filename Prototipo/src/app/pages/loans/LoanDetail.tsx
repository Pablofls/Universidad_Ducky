import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { ArrowLeft, RefreshCw, CheckCircle2, AlertCircle, Calendar } from "lucide-react";
import { Button } from "../../components/ui/Button";
import { Badge } from "../../components/ui/badge";
import { mockLoans } from "../../data/loans";

export function LoanDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [showRenewModal, setShowRenewModal] = useState(false);

  const loan = mockLoans.find((l) => l.id === id);

  if (!loan) {
    return (
      <div className="p-8">
        <div className="text-center py-12">
          <AlertCircle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h2 className="font-semibold text-gray-900 mb-2">Préstamo no encontrado</h2>
          <p className="text-gray-600 mb-4">
            No se encontró el préstamo con ID: {id}
          </p>
          <Button variant="outline" onClick={() => navigate("/loans")}>
            Volver a Préstamos
          </Button>
        </div>
      </div>
    );
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const getNewDueDate = () => {
    const currentDueDate = new Date(loan.dueDate);
    currentDueDate.setDate(currentDueDate.getDate() + 14); // 14 días más
    return currentDueDate.toISOString().split("T")[0];
  };

  const canRenew = loan.status === "Active" && loan.renewalCount < 2;

  const handleRenew = () => {
    alert("Préstamo renovado exitosamente");
    setShowRenewModal(false);
    navigate("/loans");
  };

  const getStatusBadge = () => {
    switch (loan.status) {
      case "Active":
        return <Badge variant="success">Activo</Badge>;
      case "Overdue":
        return <Badge variant="error">Atrasado</Badge>;
      case "Returned":
        return <Badge variant="default">Devuelto</Badge>;
    }
  };

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <Button
          variant="ghost"
          onClick={() => navigate("/loans")}
          className="mb-4"
        >
          <ArrowLeft className="h-4 w-4" />
          Volver a Préstamos
        </Button>
        <div className="flex items-start justify-between">
          <div>
            <h1 className="mb-2">Detalle del Préstamo</h1>
            <p className="text-gray-600">{loan.id}</p>
          </div>
          {getStatusBadge()}
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Information */}
        <div className="lg:col-span-2 space-y-6">
          {/* Loan Information */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">
              Información del Préstamo
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">
                  ID de Préstamo
                </label>
                <p className="font-medium text-gray-900">{loan.id}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">Estado</label>
                {getStatusBadge()}
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">
                  Fecha de Préstamo
                </label>
                <p className="font-medium text-gray-900">
                  {formatDate(loan.loanDate)}
                </p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">
                  Fecha de Vencimiento
                </label>
                <p className="font-medium text-gray-900">{formatDate(loan.dueDate)}</p>
              </div>
              {loan.returnDate && (
                <div>
                  <label className="block text-sm text-gray-600 mb-1">
                    Fecha de Devolución
                  </label>
                  <p className="font-medium text-gray-900">
                    {formatDate(loan.returnDate)}
                  </p>
                </div>
              )}
              <div>
                <label className="block text-sm text-gray-600 mb-1">
                  Renovaciones Realizadas
                </label>
                <p className="font-medium text-gray-900">
                  {loan.renewalCount} de 2
                </p>
              </div>
            </div>
          </div>

          {/* User Information */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">
              Información del Usuario
            </h2>
            <div className="space-y-3">
              <div>
                <label className="block text-sm text-gray-600 mb-1">Nombre</label>
                <p className="font-medium text-gray-900">{loan.userName}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">
                  ID de Usuario
                </label>
                <p className="font-medium text-gray-900">{loan.userId}</p>
              </div>
            </div>
          </div>

          {/* Book Information */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">
              Información del Libro
            </h2>
            <div className="space-y-3">
              <div>
                <label className="block text-sm text-gray-600 mb-1">Título</label>
                <p className="font-medium text-gray-900">{loan.bookTitle}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">
                  ID de Copia
                </label>
                <p className="font-medium text-gray-900">{loan.copyId}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Actions Sidebar */}
        <div className="space-y-6">
          {/* Renewal Section */}
          {loan.status === "Active" && (
            <div className="bg-white rounded-lg border border-gray-200 p-6">
              <h2 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
                <RefreshCw className="h-5 w-5" />
                Renovar Préstamo
              </h2>

              {canRenew ? (
                <div className="space-y-4">
                  <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                    <div className="flex items-start gap-2">
                      <CheckCircle2 className="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" />
                      <div>
                        <p className="text-sm font-medium text-green-900 mb-1">
                          Renovación Disponible
                        </p>
                        <p className="text-xs text-green-700">
                          Puedes renovar este préstamo
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Vencimiento actual:</span>
                      <span className="font-medium text-gray-900">
                        {formatDate(loan.dueDate)}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Nuevo vencimiento:</span>
                      <span className="font-medium text-[var(--primary)]">
                        {formatDate(getNewDueDate())}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Renovaciones:</span>
                      <span className="font-medium text-gray-900">
                        {loan.renewalCount} de 2
                      </span>
                    </div>
                  </div>

                  <Button
                    variant="primary"
                    className="w-full"
                    onClick={() => setShowRenewModal(true)}
                  >
                    <RefreshCw className="h-4 w-4" />
                    Renovar Préstamo
                  </Button>
                </div>
              ) : (
                <div className="bg-red-50 border border-red-200 rounded-lg p-3">
                  <div className="flex items-start gap-2">
                    <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
                    <div>
                      <p className="text-sm font-medium text-red-900 mb-1">
                        No se puede renovar
                      </p>
                      <p className="text-xs text-red-700">
                        {loan.renewalCount >= 2
                          ? "Se alcanzó el límite de renovaciones (2)"
                          : "El préstamo está vencido"}
                      </p>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Quick Actions */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">Acciones Rápidas</h2>
            <div className="space-y-3">
              {loan.status !== "Returned" && (
                <Button
                  variant="outline"
                  className="w-full justify-start"
                  onClick={() => navigate(`/loans/return?loanId=${loan.id}`)}
                >
                  <CheckCircle2 className="h-4 w-4" />
                  Registrar Devolución
                </Button>
              )}
              <Button
                variant="outline"
                className="w-full justify-start"
                onClick={() => navigate(`/users/${loan.userId}`)}
              >
                Ver Perfil del Usuario
              </Button>
              <Button
                variant="outline"
                className="w-full justify-start"
                onClick={() => navigate(`/copies/${loan.copyId}`)}
              >
                Ver Detalle de Copia
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Renew Confirmation Modal */}
      {showRenewModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-[var(--primary)]/10 rounded-full flex items-center justify-center mx-auto mb-4">
                <RefreshCw className="h-8 w-8 text-[var(--primary)]" />
              </div>
              <h2 className="font-semibold text-gray-900 mb-2">
                Confirmar Renovación
              </h2>
              <p className="text-sm text-gray-600">
                ¿Estás seguro de renovar este préstamo?
              </p>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-6 space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Préstamo:</span>
                <span className="font-medium text-gray-900">{loan.id}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Vencimiento actual:</span>
                <span className="font-medium text-gray-900">
                  {formatDate(loan.dueDate)}
                </span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Nuevo vencimiento:</span>
                <span className="font-medium text-[var(--primary)]">
                  {formatDate(getNewDueDate())}
                </span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-600">Renovaciones:</span>
                <span className="font-medium text-gray-900">
                  {loan.renewalCount + 1} de 2
                </span>
              </div>
            </div>

            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => setShowRenewModal(false)}
                className="flex-1"
              >
                Cancelar
              </Button>
              <Button variant="primary" onClick={handleRenew} className="flex-1">
                Confirmar
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}