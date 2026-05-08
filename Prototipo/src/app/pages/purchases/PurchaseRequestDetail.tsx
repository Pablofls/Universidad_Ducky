import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { ArrowLeft, Calendar, User, Package, FileText, CheckCircle, XCircle } from "lucide-react";
import { mockPurchaseRequests } from "../../data/mockData";
import { PurchaseRequest, PurchaseRequestStatus } from "../../types";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { StatusBadge } from "../../components/ui/StatusBadge";
import { Textarea } from "../../components/ui/Textarea";

export function PurchaseRequestDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [request, setRequest] = useState<PurchaseRequest | undefined>(
    mockPurchaseRequests.find((r) => r.id === id)
  );
  const [notes, setNotes] = useState(request?.notes || "");

  if (!request) {
    return (
      <div className="p-8">
        <p className="text-gray-500">Solicitud no encontrada</p>
      </div>
    );
  }

  const handleStatusChange = (newStatus: PurchaseRequestStatus) => {
    setRequest({
      ...request,
      status: newStatus,
      updatedAt: new Date().toISOString().split("T")[0],
      notes: notes || request.notes,
    });
  };

  const canChangeStatus = request.status === "Pending" || request.status === "Approved";

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: "Solicitudes de Compra", href: "/purchases" },
            { label: request.id },
          ]}
        />
        <div className="flex items-center gap-4 mt-4">
          <Button variant="ghost" onClick={() => navigate("/purchases")}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div className="flex-1">
            <div className="flex items-center gap-3">
              <h1 className="text-gray-900">Solicitud {request.id}</h1>
              <StatusBadge status={request.status} type="purchase" />
            </div>
            <p className="text-gray-600 mt-1">Detalles de la solicitud de compra</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Book Information */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">Información del Libro</h2>
            <div className="space-y-4">
              <div>
                <label className="text-sm text-gray-500">Título</label>
                <p className="font-medium text-gray-900">{request.bookTitle}</p>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm text-gray-500">Autor</label>
                  <p className="font-medium text-gray-900">{request.author}</p>
                </div>
                <div>
                  <label className="text-sm text-gray-500">Tema</label>
                  <p className="font-medium text-gray-900">{request.topic}</p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm text-gray-500">Editorial</label>
                  <p className="font-medium text-gray-900">{request.publisher}</p>
                </div>
                {request.bookIsbn && (
                  <div>
                    <label className="text-sm text-gray-500">ISBN</label>
                    <p className="font-medium text-gray-900">{request.bookIsbn}</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Request Details */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">Detalles de Solicitud</h2>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm text-gray-500">Cantidad de Ejemplares</label>
                  <p className="font-medium text-gray-900">{request.quantity}</p>
                </div>
                <div>
                  <label className="text-sm text-gray-500">Precio Unitario</label>
                  <p className="font-medium text-gray-900">
                    {request.price ? `$${request.price.toFixed(2)}` : 'No especificado'}
                  </p>
                </div>
              </div>
              {request.price && (
                <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                  <label className="text-sm text-gray-500">Total de Compra</label>
                  <p className="text-2xl font-bold text-gray-900">
                    ${(request.price * request.quantity).toFixed(2)}
                  </p>
                </div>
              )}
              <div>
                <label className="text-sm text-gray-500">Justificación</label>
                <p className="text-gray-900">{request.justification}</p>
              </div>
            </div>
          </div>

          {/* Notes */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h2 className="font-semibold text-gray-900 mb-4">Notas Administrativas</h2>
            <Textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Agregar notas sobre esta solicitud..."
              rows={4}
            />
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Status Actions */}
          {canChangeStatus && (
            <div className="bg-white rounded-lg border border-gray-200 p-6">
              <h3 className="font-semibold text-gray-900 mb-4">Acciones</h3>
              <div className="space-y-2">
                {request.status === "Pending" && (
                  <>
                    <Button
                      onClick={() => handleStatusChange("Approved")}
                      className="w-full justify-center bg-green-600 hover:bg-green-700"
                    >
                      <CheckCircle className="h-4 w-4" />
                      Aprobar Solicitud
                    </Button>
                    <Button
                      onClick={() => handleStatusChange("Rejected")}
                      variant="ghost"
                      className="w-full justify-center text-red-600 hover:bg-red-50"
                    >
                      <XCircle className="h-4 w-4" />
                      Rechazar Solicitud
                    </Button>
                  </>
                )}
                {request.status === "Approved" && (
                  <Button
                    onClick={() => handleStatusChange("Purchased")}
                    className="w-full justify-center"
                  >
                    <Package className="h-4 w-4" />
                    Marcar como Comprado
                  </Button>
                )}
              </div>
            </div>
          )}

          {/* Metadata */}
          <div className="bg-white rounded-lg border border-gray-200 p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Información</h3>
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <User className="h-5 w-5 text-gray-400 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-500">Solicitado por</p>
                  <p className="font-medium text-gray-900">{request.requestedBy}</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Calendar className="h-5 w-5 text-gray-400 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-500">Fecha de solicitud</p>
                  <p className="font-medium text-gray-900">{request.createdAt}</p>
                </div>
              </div>
              {request.updatedAt && (
                <div className="flex items-start gap-3">
                  <Calendar className="h-5 w-5 text-gray-400 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Última actualización</p>
                    <p className="font-medium text-gray-900">{request.updatedAt}</p>
                  </div>
                </div>
              )}
              {request.notes && (
                <div className="flex items-start gap-3">
                  <FileText className="h-5 w-5 text-gray-400 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Notas</p>
                    <p className="text-gray-900">{request.notes}</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}