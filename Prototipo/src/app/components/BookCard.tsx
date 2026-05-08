import { Book as BookType } from "../types";
import { Book, Eye, Edit, Trash2, ShoppingCart } from "lucide-react";
import { Card, CardContent, CardHeader } from "./ui/Card";
import { Button } from "./ui/Button";
import { useNavigate } from "react-router";

interface BookCardProps {
  book: BookType;
  onDelete?: (isbn: string) => void;
  onRequestPurchase?: (book: BookType) => void;
}

export function BookCard({ book, onDelete, onRequestPurchase }: BookCardProps) {
  const navigate = useNavigate();

  return (
    <Card>
      <CardHeader className="pb-4">
        <div className="flex items-start gap-4">
          <div className="w-12 h-12 bg-[var(--primary)] bg-opacity-10 rounded-lg flex items-center justify-center flex-shrink-0">
            <Book className="h-6 w-6 text-[var(--primary)]" />
          </div>
          <div className="flex-1 min-w-0">
            <h3 className="font-medium text-gray-900 truncate">{book.title}</h3>
            <p className="text-sm text-gray-600">{book.author}</p>
          </div>
        </div>
      </CardHeader>
      <CardContent className="pt-4 space-y-3">
        <div className="grid grid-cols-2 gap-2 text-sm">
          <div>
            <span className="text-gray-500">ISBN:</span>
            <p className="font-medium text-gray-900">{book.isbn}</p>
          </div>
          <div>
            <span className="text-gray-500">Tema:</span>
            <p className="font-medium text-gray-900">{book.topic}</p>
          </div>
          <div>
            <span className="text-gray-500">Editorial:</span>
            <p className="font-medium text-gray-900">{book.publisher}</p>
          </div>
          <div>
            <span className="text-gray-500">Ejemplares:</span>
            <p className="font-medium text-gray-900">
              {book.availableCopies}/{book.totalCopies}
            </p>
          </div>
        </div>

        <div className="flex gap-2 pt-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate(`/books/${book.isbn}`)}
            className="flex-1"
          >
            <Eye className="h-4 w-4" />
            Ver
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate(`/books/${book.isbn}/edit`)}
            className="flex-1"
          >
            <Edit className="h-4 w-4" />
            Editar
          </Button>
          {onRequestPurchase && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onRequestPurchase(book)}
              className="flex-1 text-[var(--primary)] hover:bg-green-50"
              title="Solicitar Compra"
            >
              <ShoppingCart className="h-4 w-4" />
            </Button>
          )}
          {onDelete && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onDelete(book.isbn)}
              className="text-[var(--error)] hover:bg-red-50"
              title="Eliminar"
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}