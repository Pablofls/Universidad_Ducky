import { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { Search, AlertCircle, CheckCircle2 } from "lucide-react";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { Badge } from "../../components/ui/badge";
import { Select } from "../../components/ui/Select";
import { mockLoans } from "../../data/loans";
import { Loan, CopyCondition } from "../../types";

export function ReturnBook() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedLoan, setSelectedLoan] = useState<Loan | null>(null);
  const [bookCondition, setBookCondition] = useState<CopyCondition>("Good");
  const [showConfirmModal, setShowConfirmModal] = useState(false);

  // Pre-fill if loanId is in URL
  useEffect(() => {
    const loanId = searchParams.get("loanId");
    if (loanId) {
      const loan = mockLoans.find((l) => l.id === loanId);
      if (loan) {
        setSelectedLoan(loan);
      }
    }
  }, [searchParams]);

  const handleSearch = () => {
    const loan = mockLoans.find(
      (l) =>
        (l.id.toLowerCase() === searchQuery.toLowerCase() ||
          l.userId.toLowerCase() === searchQuery.toLowerCase() ||
          l.copyId.toLowerCase() === searchQuery.toLowerCase()) &&
        l.status !== "Returned"
    );

    if (loan) {
      setSelectedLoan(loan);
    } else {
      alert("No se encontró un préstamo activo con esa información");
    }
  };

  const calculateBusinessDays = (startDate: string, endDate: string) => {
    const start = new Date(startDate);
    const end = new Date(endDate);
    let count = 0;
    const current = new Date(start);

    while (current <= end) {
      const dayOfWeek = current.getDay();
      // Count only weekdays (Monday = 1 to Friday = 5)
      if (dayOfWeek !== 0 && dayOfWeek !== 6) {
        count++;
      }
      current.setDate(current.getDate() + 1);
    }
    return count;
  };

  const calculateDaysOverdue = (dueDate: string) => {
    const today = new Date("2026-05-04"); // Using the current date from context
    const due = new Date(dueDate);

    if (today <= due) return 0;

    // Calculate business days overdue
    return calculateBusinessDays(due.toISOString().split('T')[0], today.toISOString().split('T')[0]);
  };

  const calculateLateFine = (daysOverdue: number) => {
    return daysOverdue * 10; // $10 per business day
  };

  const calculateDamageFine = (condition: CopyCondition, bookPrice: number) => {
    // Solo se aplica multa si el libro está Dañado
    if (condition === "Damaged") {
      return bookPrice;
    }
    return 0; // Good, Fair, or Poor - no damage fine
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const daysOverdue = selectedLoan ? calculateDaysOverdue(selectedLoan.dueDate) : 0;
  const lateFine = calculateLateFine(daysOverdue);
  const damageFine = selectedLoan ? calculateDamageFine(bookCondition, selectedLoan.bookPrice) : 0;
  const totalFine = lateFine + damageFine;
  const hasOverdue = daysOverdue > 0;
  const hasDamage = damageFine > 0;

  const handleConfirmReturn = () => {
    setShowConfirmModal(false);
    alert("Devolución registrada exitosamente");
    navigate("/loans");
  };

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="mb-2">Devolver Libro</h1>
        <p className="text-gray-600">Registra la devolución de un libro prestado</p>
      </div>

      {/* Search Section */}
      <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Buscar Préstamo
        </label>
        <div className="flex gap-3">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              type="text"
              placeholder="ID de préstamo, ID de usuario o ID de copia..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyPress={(e) => e.key === "Enter" && handleSearch()}
              className="pl-10"
            />
          </div>
          <Button variant="primary" onClick={handleSearch}>
            Buscar
          </Button>
        </div>
      </div>

      {/* Loan Information */}
      {selectedLoan && (
        <div className="bg-white rounded-lg border border-gray-200 p-6 mb-6">
          <h2 className="font-semibold text-gray-900 mb-6">Información del Préstamo</h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div className="space-y-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">ID de Préstamo</label>
                <p className="font-medium text-gray-900">{selectedLoan.id}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">Usuario</label>
                <p className="font-medium text-gray-900">{selectedLoan.userName}</p>
                <p className="text-sm text-gray-500">{selectedLoan.userId}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">Libro</label>
                <p className="font-medium text-gray-900">{selectedLoan.bookTitle}</p>
                <p className="text-sm text-gray-500">Copia: {selectedLoan.copyId}</p>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm text-gray-600 mb-1">Fecha de Préstamo</label>
                <p className="font-medium text-gray-900">{formatDate(selectedLoan.loanDate)}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">Fecha de Vencimiento</label>
                <p className="font-medium text-gray-900">{formatDate(selectedLoan.dueDate)}</p>
              </div>
              <div>
                <label className="block text-sm text-gray-600 mb-1">Estado</label>
                {selectedLoan.status === "Active" && (
                  <Badge variant="success">Activo</Badge>
                )}
                {selectedLoan.status === "Overdue" && (
                  <Badge variant="error">Atrasado</Badge>
                )}
              </div>
            </div>
          </div>

          {/* Book Condition Selection */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Condición del Libro al Regresar
            </label>
            <Select
              value={bookCondition}
              onChange={(e) => setBookCondition(e.target.value as CopyCondition)}
            >
              <option value="Good">Buena - Sin daños</option>
              <option value="Fair">Regular - Daños menores</option>
              <option value="Poor">Mala - Daños moderados</option>
              <option value="Damaged">
                Dañada - Daños severos (Multa: ${selectedLoan?.bookPrice.toFixed(2)})
              </option>
            </Select>
          </div>

          {/* Fines Summary */}
          {(hasOverdue || hasDamage) && (
            <div className="bg-red-50 border-2 border-red-500 rounded-lg p-4 mb-4">
              <div className="flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <h3 className="font-medium text-red-900 mb-3">
                    Multas Generadas
                  </h3>
                  <div className="space-y-3">
                    {hasOverdue && (
                      <div className="pb-3 border-b border-red-200">
                        <h4 className="text-sm font-medium text-red-800 mb-2">
                          Multa por Retraso
                        </h4>
                        <div className="space-y-1">
                          <div className="flex justify-between">
                            <span className="text-sm text-red-700">Días hábiles de retraso:</span>
                            <span className="text-sm font-medium text-red-900">
                              {daysOverdue} días
                            </span>
                          </div>
                          <div className="flex justify-between">
                            <span className="text-sm text-red-700">Costo por día hábil:</span>
                            <span className="text-sm font-medium text-red-900">$10</span>
                          </div>
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-red-800">Subtotal:</span>
                            <span className="text-sm font-bold text-red-900">${lateFine.toFixed(2)}</span>
                          </div>
                        </div>
                      </div>
                    )}
                    {hasDamage && (
                      <div className={hasOverdue ? "pt-0" : ""}>
                        <h4 className="text-sm font-medium text-red-800 mb-2">
                          Multa por Libro Dañado
                        </h4>
                        <div className="space-y-1">
                          <div className="flex justify-between">
                            <span className="text-sm text-red-700">Condición:</span>
                            <span className="text-sm font-medium text-red-900">Dañada</span>
                          </div>
                          <div className="flex justify-between">
                            <span className="text-sm text-red-700">Costo del libro:</span>
                            <span className="text-sm font-medium text-red-900">
                              ${selectedLoan?.bookPrice.toFixed(2)}
                            </span>
                          </div>
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-red-800">Subtotal:</span>
                            <span className="text-sm font-bold text-red-900">${damageFine.toFixed(2)}</span>
                          </div>
                        </div>
                      </div>
                    )}
                    <div className="border-t-2 border-red-300 pt-2 flex justify-between">
                      <span className="text-base font-bold text-red-800">
                        Total de Multas:
                      </span>
                      <span className="text-xl font-bold text-red-900">${totalFine.toFixed(2)}</span>
                    </div>
                  </div>
                  <p className="text-xs text-red-700 mt-3">
                    {hasOverdue && "El período máximo de préstamo es de 5 días hábiles. "}
                    {hasDamage && "La multa por libro dañado corresponde al costo completo del libro. "}
                    Estas multas serán registradas y deberán ser pagadas antes de realizar nuevos préstamos.
                  </p>
                </div>
              </div>
            </div>
          )}

          {!hasOverdue && !hasDamage && (
            <div className="bg-green-50 border-2 border-green-500 rounded-lg p-4">
              <div className="flex items-start gap-3">
                <CheckCircle2 className="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" />
                <div>
                  <h3 className="font-medium text-green-900 mb-1">
                    Devolución Sin Multas
                  </h3>
                  <p className="text-sm text-green-700">
                    {bookCondition === "Good"
                      ? "El libro fue devuelto a tiempo y en buenas condiciones. No se generarán multas."
                      : "El libro fue devuelto a tiempo. Solo se aplica multa por daños severos (libro dañado)."}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Action Buttons */}
      {selectedLoan && (
        <div className="flex justify-end gap-3">
          <Button variant="outline" onClick={() => navigate("/loans")}>
            Cancelar
          </Button>
          <Button variant="primary" onClick={() => setShowConfirmModal(true)}>
            Confirmar Devolución
          </Button>
        </div>
      )}

      {/* Confirmation Modal */}
      {showConfirmModal && selectedLoan && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-lg w-full p-6">
            <h2 className="font-semibold text-gray-900 mb-4">
              Confirmar Devolución
            </h2>

            <div className="mb-6">
              <p className="text-gray-600 mb-4">
                ¿Estás seguro de registrar la devolución de este libro?
              </p>

              <div className="bg-gray-50 rounded-lg p-4 space-y-2">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Usuario:</span>
                  <span className="text-sm font-medium text-gray-900">
                    {selectedLoan.userName}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Libro:</span>
                  <span className="text-sm font-medium text-gray-900">
                    {selectedLoan.bookTitle}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Condición:</span>
                  <span className={`text-sm font-medium ${bookCondition === "Damaged" ? "text-red-900" : "text-gray-900"}`}>
                    {bookCondition === "Good" && "Buena"}
                    {bookCondition === "Fair" && "Regular"}
                    {bookCondition === "Poor" && "Mala"}
                    {bookCondition === "Damaged" && "Dañada"}
                  </span>
                </div>
                {(hasOverdue || hasDamage) && (
                  <>
                    <div className="border-t border-gray-200 pt-2">
                      {hasOverdue && (
                        <div className="flex justify-between mb-1">
                          <span className="text-sm text-red-600">Multa por retraso:</span>
                          <span className="text-sm font-medium text-red-900">${lateFine.toFixed(2)}</span>
                        </div>
                      )}
                      {hasDamage && (
                        <div className="flex justify-between mb-1">
                          <span className="text-sm text-red-600">Multa por libro dañado:</span>
                          <span className="text-sm font-medium text-red-900">${damageFine.toFixed(2)}</span>
                        </div>
                      )}
                      <div className="border-t border-red-200 mt-2 pt-2 flex justify-between">
                        <span className="text-sm font-bold text-red-700">Total de multas:</span>
                        <span className="text-base font-bold text-red-900">${totalFine.toFixed(2)}</span>
                      </div>
                    </div>
                  </>
                )}
              </div>
            </div>

            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => setShowConfirmModal(false)}
                className="flex-1"
              >
                Cancelar
              </Button>
              <Button variant="primary" onClick={handleConfirmReturn} className="flex-1">
                Confirmar
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}