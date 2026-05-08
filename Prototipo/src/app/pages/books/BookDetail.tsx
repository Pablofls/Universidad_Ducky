import { useParams, useNavigate } from "react-router";
import { ArrowLeft, Edit, Eye, MapPin } from "lucide-react";
import { mockBooks, mockCopies } from "../../data/mockData";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";
import { StatusBadge } from "../../components/ui/StatusBadge";
import { useAuth } from "../../context/AuthContext";

export function BookDetail() {
  const { isbn } = useParams();
  const navigate = useNavigate();
  const { currentUser } = useAuth();
  const book = mockBooks.find((b) => b.isbn === isbn);
  const bookCopies = mockCopies.filter((c) => c.bookIsbn === isbn);

  if (!book) {
    return (
      <div className="p-8">
        <p className="text-gray-600">Libro no encontrado</p>
      </div>
    );
  }

  const isStudent = currentUser?.role === "Student";

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: isStudent ? "Buscar Libros" : "Libros", href: isStudent ? "/student/search" : "/books" },
            { label: book.title },
          ]}
        />
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm" onClick={() => navigate(isStudent ? "/student/search" : "/books")}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-gray-900">{book.title}</h1>
              <p className="text-gray-600 mt-1">{book.author}</p>
            </div>
          </div>
          {!isStudent && (
            <Button onClick={() => navigate(`/books/${book.isbn}/edit`)}>
              <Edit className="h-5 w-5" />
              Editar Libro
            </Button>
          )}
        </div>
      </div>

      {/* Book Details */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <h3>Información Bibliográfica</h3>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">ISBN</p>
                <p className="text-gray-900 font-medium">{book.isbn}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Tema</p>
                <p className="text-gray-900 font-medium">{book.topic}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Autor</p>
                <p className="text-gray-900 font-medium">{book.author}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Editorial</p>
                <p className="text-gray-900 font-medium">{book.publisher}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Sección</p>
                <p className="text-gray-900 font-medium">{book.genre || 'No especificada'}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Precio</p>
                <p className="text-gray-900 font-medium">
                  {book.price ? `$${book.price.toFixed(2)}` : 'No especificado'}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Agregado al Catálogo</p>
                <p className="text-gray-900 font-medium">
                  {new Date(book.createdAt).toLocaleDateString("es-ES", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <h3>Disponibilidad</h3>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <p className="text-sm text-gray-500 mb-1">Ejemplares Totales</p>
              <p className="text-3xl font-semibold text-gray-900">{book.totalCopies}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500 mb-1">Disponibles</p>
              <p className="text-3xl font-semibold text-green-600">
                {book.availableCopies}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500 mb-1">En Préstamo</p>
              <p className="text-3xl font-semibold text-amber-600">
                {book.totalCopies - book.availableCopies}
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Copies List - Ubicación Física */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <MapPin className="h-5 w-5 text-[var(--primary)]" />
              <h3>Ubicación Física de Ejemplares</h3>
            </div>
            {!isStudent && (
              <Button
                size="sm"
                variant="ghost"
                onClick={() => navigate("/copies")}
              >
                <Eye className="h-4 w-4" />
                Ver Todos los Ejemplares
              </Button>
            )}
          </div>
        </CardHeader>
        <CardContent>
          {bookCopies.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      ID Ejemplar
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Estado
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                      Ubicación
                    </th>
                    {!isStudent && (
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                        Condición
                      </th>
                    )}
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {bookCopies.map((copy) => (
                    <tr
                      key={copy.id}
                      className={!isStudent ? "hover:bg-gray-50 cursor-pointer transition-colors" : ""}
                      onClick={!isStudent ? () => navigate(`/copies/${copy.id}`) : undefined}
                    >
                      <td className="px-4 py-3 text-sm font-medium text-gray-900">
                        {copy.id}
                      </td>
                      <td className="px-4 py-3">
                        <StatusBadge status={copy.status} type="copy" />
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-2">
                          <MapPin className="h-4 w-4 text-gray-400" />
                          <span className="text-sm text-gray-900 font-medium">{copy.location}</span>
                        </div>
                      </td>
                      {!isStudent && (
                        <td className="px-4 py-3 text-sm text-gray-600">
                          {copy.condition}
                        </td>
                      )}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              No hay ejemplares disponibles para este libro
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}