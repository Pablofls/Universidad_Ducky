import { useParams, useNavigate } from "react-router";
import { ArrowLeft, MapPin, Calendar, FileText } from "lucide-react";
import { mockCopies, mockBooks } from "../../data/mockData";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";
import { StatusBadge } from "../../components/ui/StatusBadge";

export function CopyDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const copy = mockCopies.find((c) => c.id === id);
  const book = mockBooks.find((b) => b.isbn === copy?.bookIsbn);

  if (!copy) {
    return (
      <div className="p-8">
        <p className="text-gray-600">Copy not found</p>
      </div>
    );
  }

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: "Copies", href: "/copies" },
            { label: copy.id },
          ]}
        />
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm" onClick={() => navigate("/copies")}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-gray-900">Copy {copy.id}</h1>
              <p className="text-gray-600 mt-1">{copy.bookTitle}</p>
            </div>
          </div>
          <StatusBadge status={copy.status} type="copy" />
        </div>
      </div>

      {/* Copy Details */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <h3>Copy Information</h3>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">Copy ID</p>
                <p className="text-gray-900 font-medium">{copy.id}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Book ISBN</p>
                <p className="text-gray-900 font-medium">{copy.bookIsbn}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Book Title</p>
                <p className="text-gray-900 font-medium">{copy.bookTitle}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Condition</p>
                <p className="text-gray-900 font-medium">{copy.condition}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Added to Inventory</p>
                <p className="text-gray-900 font-medium">
                  {new Date(copy.createdAt).toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })}
                </p>
              </div>
            </div>

            <div className="pt-4 border-t border-gray-200">
              <div className="flex items-start gap-3">
                <MapPin className="h-5 w-5 text-gray-400 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-500">Physical Location</p>
                  <p className="text-gray-900 font-medium">{copy.location}</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <h3>Status</h3>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <p className="text-sm text-gray-500 mb-2">Current Status</p>
              <StatusBadge status={copy.status} type="copy" />
            </div>
            {copy.status === "Loaned" && (
              <div className="pt-4 border-t border-gray-200">
                <p className="text-sm text-gray-500 mb-1">Due Date</p>
                <p className="text-gray-900 font-medium">March 20, 2026</p>
              </div>
            )}
            {copy.status === "Reserved" && (
              <div className="pt-4 border-t border-gray-200">
                <p className="text-sm text-gray-500 mb-1">Reserved Until</p>
                <p className="text-gray-900 font-medium">March 15, 2026</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Book Information */}
      {book && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <h3>Book Information</h3>
              <Button
                size="sm"
                variant="ghost"
                onClick={() => navigate(`/books/${book.isbn}`)}
              >
                <FileText className="h-4 w-4" />
                View Book Details
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <p className="text-sm text-gray-500 mb-1">Author</p>
                <p className="text-gray-900 font-medium">{book.author}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Topic</p>
                <p className="text-gray-900 font-medium">{book.topic}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Publisher</p>
                <p className="text-gray-900 font-medium">{book.publisher}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Total Copies</p>
                <p className="text-gray-900 font-medium">
                  {book.availableCopies}/{book.totalCopies}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* History */}
      <Card>
        <CardHeader>
          <h3>Loan History</h3>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            <div className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg">
              <Calendar className="h-5 w-5 text-gray-400 mt-0.5" />
              <div className="flex-1">
                <p className="text-sm text-gray-900 font-medium">Loaned to Emily Johnson</p>
                <p className="text-xs text-gray-500">Feb 20, 2026 - Mar 20, 2026</p>
              </div>
              <StatusBadge status="Active" type="loan" />
            </div>
            <div className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg">
              <Calendar className="h-5 w-5 text-gray-400 mt-0.5" />
              <div className="flex-1">
                <p className="text-sm text-gray-900 font-medium">Loaned to Dr. Michael Chen</p>
                <p className="text-xs text-gray-500">Jan 10, 2026 - Feb 10, 2026</p>
              </div>
              <span className="text-xs text-gray-500">Returned</span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
