import { useState } from "react";
import { useNavigate } from "react-router";
import { ArrowLeft } from "lucide-react";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Input } from "../../components/ui/Input";
import { Textarea } from "../../components/ui/Textarea";
import { Select } from "../../components/ui/Select";
import { mockBooks } from "../../data/mockData";

export function CreatePurchaseRequest() {
  const navigate = useNavigate();
  const [selectedBook, setSelectedBook] = useState("");
  const [formData, setFormData] = useState({
    bookTitle: "",
    author: "",
    topic: "",
    publisher: "",
    quantity: 1,
    price: "",
    justification: "",
  });

  const handleBookSelect = (isbn: string) => {
    setSelectedBook(isbn);
    const book = mockBooks.find((b) => b.isbn === isbn);
    if (book) {
      setFormData({
        ...formData,
        bookTitle: book.title,
        author: book.author,
        topic: book.topic,
        publisher: book.publisher,
        price: book.price?.toString() || "",
      });
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Aquí se enviaría la solicitud
    console.log("Nueva solicitud:", formData);
    navigate("/purchases");
  };

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: "Solicitudes de Compra", href: "/purchases" },
            { label: "Nueva Solicitud" },
          ]}
        />
        <div className="flex items-center gap-4 mt-4">
          <Button variant="ghost" onClick={() => navigate("/purchases")}>
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-gray-900">Nueva Solicitud de Compra</h1>
            <p className="text-gray-600 mt-1">Crear solicitud de compra de ejemplares</p>
          </div>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="max-w-3xl">
        <div className="bg-white rounded-lg border border-gray-200 p-6 space-y-6">
          <div>
            <h3 className="font-medium text-gray-900 mb-4">Información del Libro</h3>

            {/* Select Existing Book */}
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Seleccionar Libro Existente (Opcional)
                </label>
                <Select
                  value={selectedBook}
                  onChange={(e) => handleBookSelect(e.target.value)}
                >
                  <option value="">-- Seleccionar libro del catálogo --</option>
                  {mockBooks.map((book) => (
                    <option key={book.isbn} value={book.isbn}>
                      {book.title} - {book.author}
                    </option>
                  ))}
                </Select>
              </div>

              <div className="border-t border-gray-200 pt-4">
                <p className="text-sm text-gray-500 mb-4">
                  O ingrese la información manualmente:
                </p>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Título *
                    </label>
                    <Input
                      required
                      value={formData.bookTitle}
                      onChange={(e) =>
                        setFormData({ ...formData, bookTitle: e.target.value })
                      }
                      placeholder="Título del libro"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Autor *
                    </label>
                    <Input
                      required
                      value={formData.author}
                      onChange={(e) =>
                        setFormData({ ...formData, author: e.target.value })
                      }
                      placeholder="Nombre del autor"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Tema *
                    </label>
                    <Input
                      required
                      value={formData.topic}
                      onChange={(e) =>
                        setFormData({ ...formData, topic: e.target.value })
                      }
                      placeholder="Tema o categoría"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Editorial *
                    </label>
                    <Input
                      required
                      value={formData.publisher}
                      onChange={(e) =>
                        setFormData({ ...formData, publisher: e.target.value })
                      }
                      placeholder="Nombre de la editorial"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Precio *
                    </label>
                    <Input
                      required
                      value={formData.price}
                      onChange={(e) =>
                        setFormData({ ...formData, price: e.target.value })
                      }
                      placeholder="Precio del libro"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="border-t border-gray-200 pt-6">
            <h3 className="font-medium text-gray-900 mb-4">Detalles de la Solicitud</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cantidad de Ejemplares *
                </label>
                <Input
                  type="number"
                  min="1"
                  required
                  value={formData.quantity}
                  onChange={(e) =>
                    setFormData({ ...formData, quantity: parseInt(e.target.value) })
                  }
                  placeholder="1"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Justificación *
                </label>
                <Textarea
                  required
                  value={formData.justification}
                  onChange={(e) =>
                    setFormData({ ...formData, justification: e.target.value })
                  }
                  placeholder="Explique la razón de la solicitud de compra..."
                  rows={4}
                />
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 pt-6 border-t border-gray-200">
            <Button
              type="button"
              variant="ghost"
              onClick={() => navigate("/purchases")}
            >
              Cancelar
            </Button>
            <Button type="submit">Enviar Solicitud</Button>
          </div>
        </div>
      </form>
    </div>
  );
}