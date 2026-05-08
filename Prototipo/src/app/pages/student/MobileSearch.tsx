import { useState } from "react";
import { Search, Book, Eye, X, MapPin, Filter } from "lucide-react";
import { mockBooks, mockCopies } from "../../data/mockData";
import { Book as BookType } from "../../types";
import { SearchBar } from "../../components/ui/SearchBar";
import { Select } from "../../components/ui/Select";
import { Modal } from "../../components/ui/Modal";
import { Button } from "../../components/ui/Button";

export function MobileSearch() {
  const [searchTerm, setSearchTerm] = useState("");
  const [topicFilter, setTopicFilter] = useState("All");
  const [selectedBook, setSelectedBook] = useState<BookType | null>(null);
  const [showFilters, setShowFilters] = useState(false);

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
    <div className="min-h-screen bg-gray-50 pb-safe">
      {/* Header */}
      <div className="bg-[var(--primary)] text-white px-4 py-8">
        <div className="flex items-center gap-2 mb-3">
          <Search className="h-7 w-7" />
          <h1 className="text-white text-2xl font-bold">Búsqueda de Libros</h1>
        </div>
        <p className="text-white/90 text-base">
          Explora nuestro catálogo de libros
        </p>
      </div>

      {/* Search Section */}
      <div className="px-4 -mt-4">
        <div className="bg-white rounded-lg shadow-lg p-4 space-y-3">
          <SearchBar
            placeholder="Buscar libro..."
            value={searchTerm}
            onSearch={setSearchTerm}
          />
          
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="w-full flex items-center justify-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Filter className="h-4 w-4" />
            Filtros
            {topicFilter !== "All" && (
              <span className="ml-1 px-2 py-0.5 bg-[var(--primary)] text-white text-xs rounded-full">
                1
              </span>
            )}
          </button>

          {showFilters && (
            <div className="pt-2 border-t border-gray-200">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Filtrar por Tema
              </label>
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
          )}
        </div>
      </div>

      {/* Results */}
      <div className="px-4 py-4">
        <div className="mb-3">
          <p className="text-sm text-gray-600">
            {filteredBooks.length} {filteredBooks.length === 1 ? "libro encontrado" : "libros encontrados"}
          </p>
        </div>

        {filteredBooks.length > 0 ? (
          <div className="space-y-3">
            {filteredBooks.map((book) => (
              <div
                key={book.isbn}
                className="bg-white rounded-lg border border-gray-200 p-4 active:bg-gray-50 transition-colors"
              >
                <div className="flex gap-3">
                  <div className="w-12 h-16 bg-[var(--primary)] bg-opacity-10 rounded flex items-center justify-center flex-shrink-0">
                    <Book className="h-6 w-6 text-[var(--primary)]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-gray-900 text-sm mb-1 line-clamp-2">
                      {book.title}
                    </h3>
                    <p className="text-xs text-gray-600 mb-2">{book.author}</p>
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex items-center gap-1">
                        <span className={`text-xs font-medium ${book.availableCopies > 0 ? 'text-green-600' : 'text-red-600'}`}>
                          {book.availableCopies > 0 ? `${book.availableCopies} disponibles` : 'No disponible'}
                        </span>
                      </div>
                      <button
                        onClick={() => setSelectedBook(book)}
                        className="flex items-center gap-1 px-3 py-1.5 text-xs font-medium text-[var(--primary)] hover:bg-[var(--primary)] hover:bg-opacity-5 rounded-lg transition-colors"
                      >
                        <Eye className="h-3.5 w-3.5" />
                        Ver
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg border border-gray-200 p-8 text-center">
            <Search className="h-10 w-10 text-gray-400 mx-auto mb-3" />
            <p className="text-gray-500 text-sm">No se encontraron libros</p>
            <p className="text-xs text-gray-400 mt-1">
              Intenta con otros términos
            </p>
          </div>
        )}
      </div>

      {/* Book Detail Modal */}
      {selectedBook && (() => {
        const bookCopies = mockCopies.filter(copy => copy.bookIsbn === selectedBook.isbn);
        const availableCopies = bookCopies.filter(copy => copy.status === "Available");
        
        return (
          <Modal
            isOpen={!!selectedBook}
            onClose={() => setSelectedBook(null)}
            title="Detalles del Libro"
            size="md"
          >
            <div className="space-y-4">
              <div className="flex items-start gap-4">
                <div className="w-16 h-20 bg-[var(--primary)] bg-opacity-10 rounded-lg flex items-center justify-center flex-shrink-0">
                  <Book className="h-8 w-8 text-[var(--primary)]" />
                </div>
                <div className="flex-1">
                  <h3 className="font-bold text-gray-900 mb-1 text-sm">{selectedBook.title}</h3>
                  <p className="text-sm text-gray-600">{selectedBook.author}</p>
                </div>
              </div>

              <div className="border-t border-gray-200 pt-3 space-y-2">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <p className="text-xs text-gray-500">ISBN</p>
                    <p className="font-medium text-gray-900 text-sm">{selectedBook.isbn}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Tema</p>
                    <p className="font-medium text-gray-900 text-sm">{selectedBook.topic}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Editorial</p>
                    <p className="font-medium text-gray-900 text-sm">{selectedBook.publisher}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500">Disponibilidad</p>
                    <p className={`font-medium text-sm ${selectedBook.availableCopies > 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {selectedBook.availableCopies > 0
                        ? `${selectedBook.availableCopies} disponibles`
                        : "No disponible"}
                    </p>
                  </div>
                </div>
              </div>

              {/* Available Copies Location Section */}
              {availableCopies.length > 0 && (
                <div className="border-t border-gray-200 pt-3">
                  <div className="flex items-center gap-2 mb-2">
                    <MapPin className="h-4 w-4 text-[var(--primary)]" />
                    <h4 className="font-semibold text-gray-900 text-sm">Ubicación</h4>
                  </div>
                  <div className="space-y-2">
                    {availableCopies.map((copy) => (
                      <div key={copy.id} className="bg-gray-50 rounded-lg p-3 border border-gray-200">
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex-1">
                            <p className="text-xs font-medium text-gray-900">{copy.location}</p>
                            <p className="text-xs text-gray-500 mt-0.5">
                              Código: {copy.id} • {copy.condition}
                            </p>
                          </div>
                          <div className="px-2 py-0.5 bg-green-100 text-green-700 text-xs rounded font-medium">
                            Disponible
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div className="border-t border-gray-200 pt-3">
                <p className="text-xs text-gray-600">
                  {selectedBook.availableCopies > 0
                    ? "Este libro está disponible para préstamo. Acércate al mostrador de la biblioteca para solicitarlo."
                    : "Este libro no está disponible en este momento. Puedes consultar con el bibliotecario."}
                </p>
              </div>

              <div className="flex justify-end pt-2">
                <Button onClick={() => setSelectedBook(null)} className="text-sm">
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