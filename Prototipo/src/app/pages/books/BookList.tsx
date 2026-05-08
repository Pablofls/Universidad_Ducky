import { useState } from "react";
import { useNavigate } from "react-router";
import { Plus, Filter, LayoutGrid, List, Eye, Edit, Trash2, ShoppingCart, Printer } from "lucide-react";
import { mockBooks } from "../../data/mockData";
import { Book } from "../../types";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { SearchBar } from "../../components/ui/SearchBar";
import { Select } from "../../components/ui/Select";
import { Input } from "../../components/ui/Input";
import { Textarea } from "../../components/ui/Textarea";
import { ConfirmDialog } from "../../components/ui/ConfirmDialog";
import { Modal } from "../../components/ui/Modal";
import { BookCard } from "../../components/BookCard";

export function BookList() {
  const navigate = useNavigate();
  const [books, setBooks] = useState<Book[]>(mockBooks);
  const [searchTerm, setSearchTerm] = useState("");
  const [topicFilter, setTopicFilter] = useState("All");
  const [deleteBook, setDeleteBook] = useState<Book | null>(null);
  const [purchaseBook, setPurchaseBook] = useState<Book | null>(null);
  const [purchaseQuantity, setPurchaseQuantity] = useState(1);
  const [purchaseJustification, setPurchaseJustification] = useState("");
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid");

  const topics = ["All", ...Array.from(new Set(mockBooks.map((b) => b.topic)))];

  const filteredBooks = books.filter((book) => {
    const matchesSearch =
      book.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.author.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.isbn.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.publisher.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesTopic = topicFilter === "All" || book.topic === topicFilter;

    return matchesSearch && matchesTopic;
  });

  const handleDelete = () => {
    if (deleteBook) {
      setBooks(books.filter((b) => b.isbn !== deleteBook.isbn));
      setDeleteBook(null);
    }
  };

  const handleRequestPurchase = (book: Book) => {
    setPurchaseBook(book);
    setPurchaseQuantity(1);
    setPurchaseJustification("");
  };

  const handleSubmitPurchaseRequest = () => {
    if (purchaseBook && purchaseJustification.trim()) {
      console.log("Solicitud de compra:", {
        book: purchaseBook,
        quantity: purchaseQuantity,
        justification: purchaseJustification,
      });
      // Aquí se enviaría la solicitud
      setPurchaseBook(null);
      setPurchaseQuantity(1);
      setPurchaseJustification("");
      // Opcionalmente redirigir a la página de solicitudes
      navigate("/purchases");
    }
  };

  const handlePrintList = () => {
    const printWindow = window.open("", "_blank");
    if (!printWindow) return;

    const currentDate = new Date().toLocaleDateString("es-ES", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });

    const filterInfo = [];
    if (searchTerm) {
      filterInfo.push(`Búsqueda: "${searchTerm}"`);
    }
    if (topicFilter !== "All") {
      filterInfo.push(`Tema: ${topicFilter}`);
    }

    const htmlContent = `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Catálogo de Libros - Universidad Ducky</title>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          
          body {
            font-family: 'Roboto Slab', serif;
            padding: 20px;
            color: #1f2937;
          }
          
          .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 3px solid #215930;
            padding-bottom: 20px;
          }
          
          .header h1 {
            color: #215930;
            font-size: 24px;
            margin-bottom: 5px;
          }
          
          .header h2 {
            font-size: 18px;
            color: #4b5563;
            font-weight: normal;
            margin-bottom: 10px;
          }
          
          .header .date {
            font-size: 12px;
            color: #6b7280;
          }
          
          .filter-info {
            background-color: #f3f4f6;
            padding: 10px 15px;
            margin-bottom: 20px;
            border-left: 4px solid #215930;
            font-size: 12px;
          }
          
          .stats {
            margin-bottom: 20px;
            font-size: 14px;
            color: #4b5563;
          }
          
          table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
          }
          
          thead {
            background-color: #215930;
            color: white;
          }
          
          th {
            padding: 12px 8px;
            text-align: left;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
          }
          
          tbody tr {
            border-bottom: 1px solid #e5e7eb;
          }
          
          tbody tr:nth-child(even) {
            background-color: #f9fafb;
          }
          
          td {
            padding: 10px 8px;
            font-size: 12px;
          }
          
          .isbn {
            font-weight: 600;
            color: #215930;
          }
          
          .title {
            font-weight: 500;
          }
          
          .available {
            color: #059669;
            font-weight: 600;
          }
          
          .price {
            text-align: right;
          }
          
          .footer {
            margin-top: 30px;
            padding-top: 15px;
            border-top: 2px solid #e5e7eb;
            text-align: center;
            font-size: 10px;
            color: #6b7280;
          }
          
          @media print {
            body {
              padding: 10px;
            }
            
            .header h1 {
              font-size: 20px;
            }
            
            .header h2 {
              font-size: 16px;
            }
            
            @page {
              margin: 1cm;
            }
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>Universidad Ducky</h1>
          <h2>Catálogo de Libros - Sistema de Gestión de Biblioteca</h2>
          <div class="date">Generado el ${currentDate}</div>
        </div>
        
        ${filterInfo.length > 0 ? `
          <div class="filter-info">
            <strong>Filtros aplicados:</strong> ${filterInfo.join(" | ")}
          </div>
        ` : ''}
        
        <div class="stats">
          <strong>Total de libros:</strong> ${filteredBooks.length} | 
          <strong>Ejemplares totales:</strong> ${filteredBooks.reduce((sum, book) => sum + book.totalCopies, 0)} | 
          <strong>Disponibles:</strong> ${filteredBooks.reduce((sum, book) => sum + book.availableCopies, 0)}
        </div>
        
        <table>
          <thead>
            <tr>
              <th style="width: 10%;">ISBN</th>
              <th style="width: 25%;">Título</th>
              <th style="width: 18%;">Autor</th>
              <th style="width: 12%;">Tema</th>
              <th style="width: 10%;">Sección</th>
              <th style="width: 10%;">Editorial</th>
              <th style="width: 5%;">Precio</th>
              <th style="width: 5%;">Disp.</th>
              <th style="width: 5%;">Total</th>
            </tr>
          </thead>
          <tbody>
            ${filteredBooks.map(book => `
              <tr>
                <td class="isbn">${book.isbn}</td>
                <td class="title">${book.title}</td>
                <td>${book.author}</td>
                <td>${book.topic}</td>
                <td>${book.genre || '-'}</td>
                <td>${book.publisher}</td>
                <td class="price">${book.price ? '$' + book.price.toFixed(2) : '-'}</td>
                <td class="available">${book.availableCopies}</td>
                <td>${book.totalCopies}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
        
        <div class="footer">
          Este documento fue generado automáticamente por el Sistema de Gestión de Biblioteca de la Universidad Ducky.
        </div>
        
        <script>
          window.onload = function() {
            window.print();
          };
        </script>
      </body>
      </html>
    `;

    printWindow.document.write(htmlContent);
    printWindow.document.close();
  };

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb items={[{ label: "Libros" }]} />
        <div className="flex items-center justify-between mt-4">
          <div>
            <h1 className="text-gray-900">Catálogo de Libros</h1>
            <p className="text-gray-600 mt-1">Administrar colección de libros de la biblioteca</p>
          </div>
          <Button onClick={() => navigate("/books/create")}>
            <Plus className="h-5 w-5" />
            Agregar Libro
          </Button>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg border border-gray-200">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2">
            <SearchBar
              placeholder="Buscar por título, autor, ISBN o editorial..."
              value={searchTerm}
              onSearch={setSearchTerm}
            />
          </div>
          <div className="flex items-center gap-2">
            <Filter className="h-5 w-5 text-gray-400" />
            <Select
              value={topicFilter}
              onChange={(e) => setTopicFilter(e.target.value)}
            >
              {topics.map((topic) => (
                <option key={topic} value={topic}>
                  {topic === "All" ? "Todos los Temas" : topic}
                </option>
              ))}
            </Select>
          </div>
        </div>
        
        {/* View Mode Toggle */}
        <div className="flex items-center justify-end gap-2 mt-4 pt-4 border-t border-gray-200">
          <span className="text-sm text-gray-600 mr-2">Vista:</span>
          <div className="inline-flex rounded-lg border border-gray-200 bg-gray-50">
            <button
              onClick={() => setViewMode("grid")}
              className={`px-3 py-1.5 rounded-l-lg transition-colors ${
                viewMode === "grid"
                  ? "bg-[var(--primary)] text-white"
                  : "bg-transparent text-gray-600 hover:bg-gray-100"
              }`}
              title="Vista de Tarjetas"
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
            <button
              onClick={() => setViewMode("list")}
              className={`px-3 py-1.5 rounded-r-lg transition-colors ${
                viewMode === "list"
                  ? "bg-[var(--primary)] text-white"
                  : "bg-transparent text-gray-600 hover:bg-gray-100"
              }`}
              title="Vista de Lista"
            >
              <List className="h-4 w-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Books Grid/List */}
      {filteredBooks.length > 0 ? (
        viewMode === "grid" ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredBooks.map((book) => (
              <BookCard
                key={book.isbn}
                book={book}
                onDelete={() => setDeleteBook(book)}
                onRequestPurchase={() => handleRequestPurchase(book)}
              />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      ISBN
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Título
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Autor
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Tema
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Sección
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Precio
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Disponibles
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Total
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Acciones
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredBooks.map((book) => (
                    <tr key={book.isbn} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {book.isbn}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {book.title}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {book.author}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {book.topic}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-600">
                        {book.genre || '-'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {book.price ? `$${book.price.toFixed(2)}` : '-'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <span className="font-semibold text-green-600">
                          {book.availableCopies}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {book.totalCopies}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => navigate(`/books/${book.isbn}`)}
                            className="text-gray-600 hover:text-[var(--primary)] transition-colors"
                            title="Ver Detalles"
                          >
                            <Eye className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => navigate(`/books/${book.isbn}/edit`)}
                            className="text-gray-600 hover:text-[var(--primary)] transition-colors"
                            title="Editar"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleRequestPurchase(book)}
                            className="text-gray-600 hover:text-[var(--primary)] transition-colors"
                            title="Solicitar Compra"
                          >
                            <ShoppingCart className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => setDeleteBook(book)}
                            className="text-gray-600 hover:text-red-600 transition-colors"
                            title="Eliminar"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )
      ) : (
        <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
          <p className="text-gray-500">No se encontraron libros</p>
        </div>
      )}

      {/* Export Button */}
      {filteredBooks.length > 0 && (
        <div className="flex justify-end">
          <Button
            onClick={handlePrintList}
            variant="outline"
          >
            <Printer className="h-5 w-5" />
            Exportar para Impresión
          </Button>
        </div>
      )}

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={!!deleteBook}
        onClose={() => setDeleteBook(null)}
        onConfirm={handleDelete}
        title="Eliminar Libro"
        message={`¿Está seguro de que desea eliminar "${deleteBook?.title}"? Esta acción no se puede deshacer.`}
        confirmText="Eliminar"
        cancelText="Cancelar"
      />

      {/* Purchase Request Modal */}
      <Modal
        isOpen={!!purchaseBook}
        onClose={() => setPurchaseBook(null)}
        title="Solicitar Compra de Libro"
      >
        <div className="space-y-4">
          <div>
            <p className="text-gray-900 font-bold">Título:</p>
            <p className="text-gray-600">{purchaseBook?.title}</p>
          </div>
          <div>
            <p className="text-gray-900 font-bold">Autor:</p>
            <p className="text-gray-600">{purchaseBook?.author}</p>
          </div>
          <div>
            <p className="text-gray-900 font-bold">ISBN:</p>
            <p className="text-gray-600">{purchaseBook?.isbn}</p>
          </div>
          <div>
            <p className="text-gray-900 font-bold">Editorial:</p>
            <p className="text-gray-600">{purchaseBook?.publisher}</p>
          </div>
          <div>
            <p className="text-gray-900 font-bold">Cantidad:</p>
            <Input
              type="number"
              value={purchaseQuantity}
              onChange={(e) => setPurchaseQuantity(Number(e.target.value))}
              min={1}
            />
          </div>
          <div>
            <p className="text-gray-900 font-bold">Justificación:</p>
            <Textarea
              value={purchaseJustification}
              onChange={(e) => setPurchaseJustification(e.target.value)}
              placeholder="Escriba la justificación para la compra..."
            />
          </div>
        </div>
        <div className="flex justify-end mt-4">
          <Button
            onClick={handleSubmitPurchaseRequest}
            disabled={!purchaseJustification.trim()}
          >
            Enviar Solicitud
          </Button>
        </div>
      </Modal>
    </div>
  );
}