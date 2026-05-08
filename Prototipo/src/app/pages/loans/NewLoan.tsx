import { useState } from "react";
import { useNavigate } from "react-router";
import { Search, User, BookOpen, AlertCircle, CheckCircle2, X } from "lucide-react";
import { Input } from "../../components/ui/Input";
import { Button } from "../../components/ui/Button";
import { Badge } from "../../components/ui/badge";
import { mockUsers, mockBooks, mockCopies } from "../../data/mockData";
import { mockLoans, mockFines } from "../../data/loans";
import { User as UserType, Copy } from "../../types";

export function NewLoan() {
  const navigate = useNavigate();
  const [userSearchQuery, setUserSearchQuery] = useState("");
  const [selectedUser, setSelectedUser] = useState<UserType | null>(null);
  const [bookSearchQuery, setBookSearchQuery] = useState("");
  const [selectedBook, setSelectedBook] = useState<any | null>(null);
  const [selectedCopy, setSelectedCopy] = useState<Copy | null>(null);
  const [showConfirmModal, setShowConfirmModal] = useState(false);
  const [showReceiptModal, setShowReceiptModal] = useState(false);
  const [newLoanId, setNewLoanId] = useState("");

  // User search
  const userSearchResults = mockUsers.filter(
    (user) =>
      userSearchQuery &&
      (user.id.toLowerCase().includes(userSearchQuery.toLowerCase()) ||
        user.name.toLowerCase().includes(userSearchQuery.toLowerCase()))
  );

  // Book search
  const bookSearchResults = mockBooks.filter(
    (book) =>
      bookSearchQuery &&
      (book.title.toLowerCase().includes(bookSearchQuery.toLowerCase()) ||
        book.author.toLowerCase().includes(bookSearchQuery.toLowerCase()) ||
        book.isbn.toLowerCase().includes(bookSearchQuery.toLowerCase()))
  );

  // Available copies for selected book
  const availableCopies = selectedBook
    ? mockCopies.filter(
        (copy) => copy.bookIsbn === selectedBook.isbn && copy.status === "Available"
      )
    : [];

  // Check user eligibility
  const getUserEligibility = (user: UserType) => {
    const userLoans = mockLoans.filter(
      (loan) => loan.userId === user.id && loan.status !== "Returned"
    );
    const activeLoans = userLoans.length;
    const hasOverdueLoans = userLoans.some((loan) => loan.status === "Overdue");
    const userFines = mockFines.filter(
      (fine) => fine.userId === user.id && fine.status === "Pending"
    );
    const hasPendingFines = userFines.length > 0;

    const isEligible = !hasPendingFines && !hasOverdueLoans && activeLoans < 3;

    return {
      isEligible,
      activeLoans,
      hasOverdueLoans,
      hasPendingFines,
      pendingFinesAmount: userFines.reduce((sum, fine) => sum + fine.amount, 0),
    };
  };

  const handleConfirmLoan = () => {
    const loanId = `LOAN-${String(mockLoans.length + 1).padStart(3, "0")}`;
    setNewLoanId(loanId);
    setShowConfirmModal(false);
    setShowReceiptModal(true);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const getTodayDate = () => {
    return new Date().toISOString().split("T")[0];
  };

  const getDueDate = () => {
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 14); // 14 días de préstamo
    return dueDate.toISOString().split("T")[0];
  };

  const eligibility = selectedUser ? getUserEligibility(selectedUser) : null;

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="mb-2">Registrar Nuevo Préstamo</h1>
        <p className="text-gray-600">Busca el usuario y selecciona el libro a prestar</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Left Column - User Information */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center gap-2 mb-4">
            <User className="h-5 w-5 text-[var(--primary)]" />
            <h2 className="font-semibold text-gray-900">Información del Usuario</h2>
          </div>

          {/* User Search */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Buscar Usuario
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
              <Input
                type="text"
                placeholder="ID de usuario o nombre..."
                value={userSearchQuery}
                onChange={(e) => setUserSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>

            {/* Search Results */}
            {userSearchQuery && userSearchResults.length > 0 && !selectedUser && (
              <div className="mt-2 border border-gray-200 rounded-lg max-h-48 overflow-y-auto">
                {userSearchResults.slice(0, 5).map((user) => (
                  <button
                    key={user.id}
                    onClick={() => {
                      setSelectedUser(user);
                      setUserSearchQuery("");
                    }}
                    className="w-full px-4 py-2 text-left hover:bg-gray-50 border-b border-gray-100 last:border-b-0"
                  >
                    <div className="text-sm font-medium text-gray-900">{user.name}</div>
                    <div className="text-xs text-gray-500">{user.id} - {user.role}</div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Selected User */}
          {selectedUser && eligibility && (
            <div className="space-y-4">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-medium text-gray-900">{selectedUser.name}</h3>
                  <p className="text-sm text-gray-600">{selectedUser.id}</p>
                </div>
                <button
                  onClick={() => setSelectedUser(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Tipo de usuario:</span>
                  <span className="text-sm font-medium text-gray-900">
                    {selectedUser.role === "Student" ? "Alumno" : "Profesor"}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Libros prestados:</span>
                  <span className="text-sm font-medium text-gray-900">
                    {eligibility.activeLoans}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Multas pendientes:</span>
                  <span className="text-sm font-medium text-gray-900">
                    ${eligibility.pendingFinesAmount}
                  </span>
                </div>
              </div>

              {/* Eligibility Status */}
              <div
                className={`p-4 rounded-lg border-2 ${
                  eligibility.isEligible
                    ? "bg-green-50 border-green-500"
                    : "bg-red-50 border-red-500"
                }`}
              >
                <div className="flex items-center gap-2 mb-2">
                  {eligibility.isEligible ? (
                    <CheckCircle2 className="h-5 w-5 text-green-600" />
                  ) : (
                    <AlertCircle className="h-5 w-5 text-red-600" />
                  )}
                  <span
                    className={`font-medium ${
                      eligibility.isEligible ? "text-green-900" : "text-red-900"
                    }`}
                  >
                    {eligibility.isEligible ? "Autorizado" : "No Autorizado"}
                  </span>
                </div>

                {!eligibility.isEligible && (
                  <ul className="text-sm text-red-800 space-y-1">
                    {eligibility.hasPendingFines && (
                      <li>• Tiene multas pendientes</li>
                    )}
                    {eligibility.hasOverdueLoans && (
                      <li>• Tiene préstamos vencidos</li>
                    )}
                    {eligibility.activeLoans >= 3 && (
                      <li>• Tiene más de 2 libros prestados</li>
                    )}
                  </ul>
                )}
              </div>
            </div>
          )}

          {!selectedUser && (
            <div className="text-center py-8">
              <User className="h-12 w-12 text-gray-400 mx-auto mb-2" />
              <p className="text-sm text-gray-500">Busca y selecciona un usuario</p>
            </div>
          )}
        </div>

        {/* Right Column - Book Selection */}
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center gap-2 mb-4">
            <BookOpen className="h-5 w-5 text-[var(--primary)]" />
            <h2 className="font-semibold text-gray-900">Selección del Libro</h2>
          </div>

          {/* Book Search */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Buscar Libro
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
              <Input
                type="text"
                placeholder="Título, autor o ISBN..."
                value={bookSearchQuery}
                onChange={(e) => setBookSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>

            {/* Book Search Results */}
            {bookSearchQuery && bookSearchResults.length > 0 && !selectedBook && (
              <div className="mt-2 border border-gray-200 rounded-lg max-h-48 overflow-y-auto">
                {bookSearchResults.slice(0, 5).map((book) => (
                  <button
                    key={book.isbn}
                    onClick={() => {
                      setSelectedBook(book);
                      setBookSearchQuery("");
                    }}
                    className="w-full px-4 py-2 text-left hover:bg-gray-50 border-b border-gray-100 last:border-b-0"
                  >
                    <div className="text-sm font-medium text-gray-900">{book.title}</div>
                    <div className="text-xs text-gray-500">
                      {book.author} - ISBN: {book.isbn}
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Available Copies */}
          {selectedBook && (
            <div className="space-y-4">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-medium text-gray-900">{selectedBook.title}</h3>
                  <p className="text-sm text-gray-600">{selectedBook.author}</p>
                </div>
                <button
                  onClick={() => {
                    setSelectedBook(null);
                    setSelectedCopy(null);
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Copias Disponibles ({availableCopies.length})
                </label>

                {availableCopies.length > 0 ? (
                  <div className="border border-gray-200 rounded-lg overflow-hidden">
                    <table className="w-full">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                            ID Copia
                          </th>
                          <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                            Ubicación
                          </th>
                          <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                            Estado
                          </th>
                          <th className="px-4 py-2"></th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-200">
                        {availableCopies.map((copy) => (
                          <tr
                            key={copy.id}
                            className={
                              selectedCopy?.id === copy.id ? "bg-green-50" : "hover:bg-gray-50"
                            }
                          >
                            <td className="px-4 py-3 text-sm text-gray-900">{copy.id}</td>
                            <td className="px-4 py-3 text-sm text-gray-600">
                              {copy.location}
                            </td>
                            <td className="px-4 py-3">
                              <Badge variant="success">Disponible</Badge>
                            </td>
                            <td className="px-4 py-3">
                              <Button
                                variant={selectedCopy?.id === copy.id ? "primary" : "outline"}
                                size="sm"
                                onClick={() => setSelectedCopy(copy)}
                              >
                                {selectedCopy?.id === copy.id ? "Seleccionado" : "Seleccionar"}
                              </Button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                ) : (
                  <div className="border border-gray-200 rounded-lg p-4 text-center">
                    <p className="text-sm text-gray-500 mb-2">
                      No hay copias disponibles
                    </p>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => navigate("/loans/waitlist")}
                    >
                      Agregar a lista de espera
                    </Button>
                  </div>
                )}
              </div>
            </div>
          )}

          {!selectedBook && (
            <div className="text-center py-8">
              <BookOpen className="h-12 w-12 text-gray-400 mx-auto mb-2" />
              <p className="text-sm text-gray-500">Busca y selecciona un libro</p>
            </div>
          )}
        </div>
      </div>

      {/* Action Buttons */}
      <div className="mt-6 flex justify-end gap-3">
        <Button variant="outline" onClick={() => navigate("/loans")}>
          Cancelar
        </Button>
        <Button
          variant="primary"
          onClick={() => setShowConfirmModal(true)}
          disabled={!selectedUser || !selectedCopy || !eligibility?.isEligible}
        >
          Registrar Préstamo
        </Button>
      </div>

      {/* Confirmation Modal */}
      {showConfirmModal && selectedUser && selectedBook && selectedCopy && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-lg w-full p-6">
            <h2 className="font-semibold text-gray-900 mb-4">Confirmar Préstamo</h2>

            <div className="space-y-3 mb-6">
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Usuario:</span>
                <span className="text-sm font-medium text-gray-900">
                  {selectedUser.name}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Libro:</span>
                <span className="text-sm font-medium text-gray-900">
                  {selectedBook.title}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">ID de Copia:</span>
                <span className="text-sm font-medium text-gray-900">
                  {selectedCopy.id}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Fecha de préstamo:</span>
                <span className="text-sm font-medium text-gray-900">
                  {formatDate(getTodayDate())}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Fecha de vencimiento:</span>
                <span className="text-sm font-medium text-gray-900">
                  {formatDate(getDueDate())}
                </span>
              </div>
            </div>

            <div className="flex gap-3">
              <Button variant="outline" onClick={() => setShowConfirmModal(false)} className="flex-1">
                Cancelar
              </Button>
              <Button variant="primary" onClick={handleConfirmLoan} className="flex-1">
                Confirmar Préstamo
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Receipt Modal */}
      {showReceiptModal && selectedUser && selectedBook && selectedCopy && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-lg w-full p-6">
            <div className="text-center mb-6">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 className="h-8 w-8 text-green-600" />
              </div>
              <h2 className="font-semibold text-gray-900 mb-2">Préstamo Registrado</h2>
              <p className="text-sm text-gray-600">Recibo de Préstamo</p>
            </div>

            <div className="border border-gray-200 rounded-lg p-4 mb-6 space-y-3">
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">ID del préstamo:</span>
                <span className="text-sm font-medium text-gray-900">{newLoanId}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Nombre del usuario:</span>
                <span className="text-sm font-medium text-gray-900">
                  {selectedUser.name}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Título del libro:</span>
                <span className="text-sm font-medium text-gray-900">
                  {selectedBook.title}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">ID de copia:</span>
                <span className="text-sm font-medium text-gray-900">
                  {selectedCopy.id}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Fecha de préstamo:</span>
                <span className="text-sm font-medium text-gray-900">
                  {formatDate(getTodayDate())}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-sm text-gray-600">Fecha de vencimiento:</span>
                <span className="text-sm font-medium text-gray-900">
                  {formatDate(getDueDate())}
                </span>
              </div>
            </div>

            <div className="space-y-3">
              <Button variant="outline" className="w-full">
                Imprimir Recibo
              </Button>
              <Button variant="outline" className="w-full">
                Enviar por Correo
              </Button>
              <Button variant="outline" className="w-full">
                Enviar por WhatsApp
              </Button>
              <Button
                variant="primary"
                className="w-full"
                onClick={() => navigate("/loans")}
              >
                Finalizar
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}