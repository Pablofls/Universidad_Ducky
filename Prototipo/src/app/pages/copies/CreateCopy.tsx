import { useState } from "react";
import { useNavigate } from "react-router";
import { mockBooks } from "../../data/mockData";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Input } from "../../components/ui/Input";
import { Select } from "../../components/ui/Select";
import { Alert } from "../../components/ui/Alert";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";

export function CreateCopy() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    id: "",
    bookIsbn: "",
    status: "Available",
    location: "",
    condition: "Good",
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [showSuccess, setShowSuccess] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation
    const newErrors: Record<string, string> = {};
    
    if (!formData.id.trim()) {
      newErrors.id = "Copy ID / Barcode is required";
    }
    if (!formData.bookIsbn.trim()) {
      newErrors.bookIsbn = "Book selection is required";
    }
    if (!formData.location.trim()) {
      newErrors.location = "Physical location is required";
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    // Simulate save
    setShowSuccess(true);
    setTimeout(() => {
      navigate("/copies");
    }, 1500);
  };

  const handleChange = (field: string, value: string) => {
    setFormData({ ...formData, [field]: value });
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors({ ...errors, [field]: "" });
    }
  };

  return (
    <div className="p-8 space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: "Copies", href: "/copies" },
            { label: "Add Copy" },
          ]}
        />
        <h1 className="text-gray-900 mt-4">Add New Copy</h1>
        <p className="text-gray-600 mt-1">Add a physical copy to the inventory</p>
      </div>

      {/* Success Alert */}
      {showSuccess && (
        <Alert variant="success">
          Copy added successfully! Redirecting...
        </Alert>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit}>
        <Card>
          <CardHeader>
            <h3>Copy Information</h3>
          </CardHeader>
          <CardContent className="space-y-6">
            <Input
              label="Copy ID / Barcode"
              placeholder="e.g., C001, BAR123456"
              value={formData.id}
              onChange={(e) => handleChange("id", e.target.value)}
              error={errors.id}
              required
            />

            <Select
              label="Book (ISBN)"
              value={formData.bookIsbn}
              onChange={(e) => handleChange("bookIsbn", e.target.value)}
              error={errors.bookIsbn}
              required
            >
              <option value="">Select a book...</option>
              {mockBooks.map((book) => (
                <option key={book.isbn} value={book.isbn}>
                  {book.isbn} - {book.title}
                </option>
              ))}
            </Select>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Select
                label="Status"
                value={formData.status}
                onChange={(e) => handleChange("status", e.target.value)}
                required
              >
                <option value="Available">Available</option>
                <option value="Loaned">Loaned</option>
                <option value="Reserved">Reserved</option>
                <option value="Internal Use">Internal Use</option>
              </Select>

              <Select
                label="Condition"
                value={formData.condition}
                onChange={(e) => handleChange("condition", e.target.value)}
                required
              >
                <option value="New">New</option>
                <option value="Good">Good</option>
                <option value="Fair">Fair</option>
                <option value="Poor">Poor</option>
                <option value="Damaged">Damaged</option>
              </Select>
            </div>

            <Input
              label="Physical Location"
              placeholder="e.g., Section A, Shelf 3, Row 2"
              value={formData.location}
              onChange={(e) => handleChange("location", e.target.value)}
              error={errors.location}
              required
            />
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex justify-end gap-3 mt-6">
          <Button type="button" variant="ghost" onClick={() => navigate("/copies")}>
            Cancel
          </Button>
          <Button type="submit" variant="primary">
            Save Copy
          </Button>
        </div>
      </form>
    </div>
  );
}
