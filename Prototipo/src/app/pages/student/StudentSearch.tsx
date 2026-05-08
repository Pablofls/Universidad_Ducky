import { useState } from "react";
import { Search, Book, Eye, X, MapPin } from "lucide-react";
import { mockBooks, mockCopies } from "../../data/mockData";
import { Book as BookType } from "../../types";
import { SearchBar } from "../../components/ui/SearchBar";
import { Select } from "../../components/ui/Select";
import { Modal } from "../../components/ui/Modal";
import { Button } from "../../components/ui/Button";

export function StudentSearch() {
  const [searchTerm, setSearchTerm] = useState("");
  const [topicFilter, setTopicFilter] = useState("All");
  const [selectedBook, setSelectedBook] = useState<BookType | null>(null);

  const topics = ["All", ...Array.from(new Set(mockBooks.map((b) => b.topic)))];

  const filteredBooks = mockBooks.filter((book) => {
    const matchesSearch =
      book.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.author.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.isbn.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.publisher.toLowerCase().includes(searchTerm.toLowerCase()) ||
      book.topic.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesTopic = topicFilter === "All" || book.topic === topicFilter;

    return matchesSearch && matchesTopic;
  });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-[var(--primary)] text-white py-12 px-8">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center gap-3 mb-4">
            <Search className="h-8 w-8" />
            <h1 className="text-white">Búsqueda de Libros</h1>
          </div>
          <p className="text-white/90">
            Explora nuestro catálogo de libros disponibles en Ducky
          </p>
        </div>
      </div>

      {/* Search Section */}
      <div className="max-w-4xl mx-auto px-8 -mt-8">
        <div className="bg-white rounded-lg shadow-lg p-6 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <SearchBar
                placeholder="Buscar por título, autor, ISBN, editorial o tema..."
                value={searchTerm}
                onSearch={setSearchTerm}
              />
            </div>
            <div>
              <Select
                value={topicFilter}
                onChange={(e) => setTopicFilter(e.target.value)}
              >
                <option value="All">Todos los Temas</option>
                {topics.slice(1).map((topic) => (
                  <option key={topic} value={topic}>
                    {topic}
                  </option>
                ))}
              </Select>
            </div>
          </div>
        </div>
      </div>

      {/* Results */}
      <div className="max-w-4xl mx-auto px-8 py-8">
        <div className="mb-4">
          <p className="text-gray-600">
            {filteredBooks.length} {filteredBooks.length === 1 ? "libro encontrado" : "libros encontrados"}
          </p>
        </div>

        {filteredBooks.length > 0 ? (
          <div className="space-y-4">
            {filteredBooks.map((book) => (
              <div
                key={book.isbn}
                className="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-md transition-shadow"
              >
                <div className="flex items-start gap-6">
                  <div className="w-16 h-20 bg-[var(--primary)] bg-opacity-10 rounded flex items-center justify-center flex-shrink-0">
                    <Book className="h-8 w-8 text-[var(--primary)]" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900 mb-2">{book.title}</h3>
                    <div className="grid grid-cols-2 gap-x-6 gap-y-2 text-sm">
                      <div>
                        <span className="text-gray-500">Autor:</span>
                        <span className="ml-2 text-gray-900">{book.author}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">ISBN:</span>
                        <span className="ml-2 text-gray-900">{book.isbn}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Tema:</span>
                        <span className="ml-2 text-gray-900">{book.topic}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Editorial:</span>
                        <span className="ml-2 text-gray-900">{book.publisher}</span>
                      </div>
                      <div>
                        <span className="text-gray-500">Disponibles:</span>
                        <span className={`ml-2 font-medium ${book.availableCopies > 0 ? 'text-green-600' : 'text-red-600'}`}>
                          {book.availableCopies} de {book.totalCopies}
                        </span>
                      </div>
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    onClick={() => setSelectedBook(book)}
                  >
                    <Eye className="h-5 w-5" />
                    Ver Detalles
                  </Button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg border border-gray-200 p-12 text-center">
            <Search className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">No se encontraron libros</p>
            <p className="text-sm text-gray-400 mt-2">
              Intenta con otros términos de búsqueda
            </p>
          </div>
        )}
      </div>

      {/* Book Detail Modal */}
      {selectedBook && (() => {
        // Get all copies for this book
        const bookCopies = mockCopies.filter(copy => copy.bookIsbn === selectedBook.isbn);
        const availableCopies = bookCopies.filter(copy => copy.status === "Available");
        
        return (
          <Modal
            isOpen={!!selectedBook}
            onClose={() => setSelectedBook(null)}
            title="Detalles del Libro"
            size="md"
          >
            <div className="space-y-6">
              <div className="flex items-start gap-6">
                <div className="w-24 h-32 bg-[var(--primary)] bg-opacity-10 rounded-lg flex items-center justify-center flex-shrink-0">
                  <Book className="h-12 w-12 text-[var(--primary)]" />
                </div>
                <div className="flex-1">
                  <h3 className="font-bold text-gray-900 mb-2">{selectedBook.title}</h3>
                  <p className="text-gray-600">{selectedBook.author}</p>
                </div>
              </div>

              <div className="border-t border-gray-200 pt-4 space-y-3">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-500">ISBN</p>
                    <p className="font-medium text-gray-900">{selectedBook.isbn}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Tema</p>
                    <p className="font-medium text-gray-900">{selectedBook.topic}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Editorial</p>
                    <p className="font-medium text-gray-900">{selectedBook.publisher}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Disponibilidad</p>
                    <p className={`font-medium ${selectedBook.availableCopies > 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {selectedBook.availableCopies > 0
                        ? `${selectedBook.availableCopies} disponibles`
                        : "No disponible"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Available Copies Location Section */}
              {availableCopies.length > 0 && (
                <div className="border-t border-gray-200 pt-4">
                  <div className="flex items-center gap-2 mb-3">
                    <MapPin className="h-5 w-5 text-[var(--primary)]" />
                    <h4 className="font-semibold text-gray-900">Ubicación de Copias Disponibles</h4>
                  </div>
                  <div className="space-y-2">
                    {availableCopies.map((copy) => (
                      <div key={copy.id} className="bg-gray-50 rounded-lg p-3 border border-gray-200">
                        <div className="flex items-start justify-between gap-3">
                          <div className="flex-1">
                            <p className="text-sm font-medium text-gray-900">{copy.location}</p>
                            <p className="text-xs text-gray-500 mt-1">
                              Código: {copy.id} • Condición: {copy.condition}
                            </p>
                          </div>
                          <div className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-md font-medium">
                            Disponible
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div className="border-t border-gray-200 pt-4">
                <p className="text-sm text-gray-600">
                  {selectedBook.availableCopies > 0
                    ? "Este libro está disponible para préstamo. Acércate al mostrador de la biblioteca para solicitarlo."
                    : "Este libro no está disponible en este momento. Puedes reservarlo o consultar con el bibliotecario."}
                </p>
              </div>

              <div className="flex justify-end">
                <Button onClick={() => setSelectedBook(null)}>
                  Cerrar
                </Button>
              </div>
            </div>
          </Modal>
        );
      })()}
    </div>
  );
}