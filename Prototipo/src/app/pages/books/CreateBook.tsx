import { useState } from "react";
import { useNavigate } from "react-router";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { Input } from "../../components/ui/Input";
import { Alert } from "../../components/ui/Alert";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";

export function CreateBook() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    isbn: "",
    title: "",
    author: "",
    topic: "",
    publisher: "",
    genre: "",
    price: "",
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [showSuccess, setShowSuccess] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation
    const newErrors: Record<string, string> = {};
    
    if (!formData.isbn.trim()) {
      newErrors.isbn = "El ISBN es requerido";
    } else if (!/^978-\d{10}$/.test(formData.isbn)) {
      newErrors.isbn = "El ISBN debe estar en formato: 978-XXXXXXXXXX";
    }
    if (!formData.title.trim()) {
      newErrors.title = "El título es requerido";
    }
    if (!formData.author.trim()) {
      newErrors.author = "El autor es requerido";
    }
    if (!formData.topic.trim()) {
      newErrors.topic = "El tema es requerido";
    }
    if (!formData.publisher.trim()) {
      newErrors.publisher = "La editorial es requerida";
    }
    if (!formData.genre.trim()) {
      newErrors.genre = "El género es requerido";
    }
    if (!formData.price.trim()) {
      newErrors.price = "El precio es requerido";
    } else if (isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      newErrors.price = "El precio debe ser un número válido mayor a 0";
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    // Simulate save
    setShowSuccess(true);
    setTimeout(() => {
      navigate("/books");
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
            { label: "Libros", href: "/books" },
            { label: "Agregar Libro" },
          ]}
        />
        <h1 className="text-gray-900 mt-4">Agregar Nuevo Libro</h1>
        <p className="text-gray-600 mt-1">Agregar un nuevo libro al catálogo</p>
      </div>

      {/* Success Alert */}
      {showSuccess && (
        <Alert variant="success">
          ¡Libro agregado exitosamente! Redirigiendo...
        </Alert>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit}>
        <Card>
          <CardHeader>
            <h3>Información del Libro</h3>
          </CardHeader>
          <CardContent className="space-y-6">
            <Input
              label="ISBN"
              placeholder="ej., 978-0134685991"
              value={formData.isbn}
              onChange={(e) => handleChange("isbn", e.target.value)}
              error={errors.isbn}
              required
            />

            <Input
              label="Título"
              placeholder="ej., Effective Java"
              value={formData.title}
              onChange={(e) => handleChange("title", e.target.value)}
              error={errors.title}
              required
            />

            <Input
              label="Autor"
              placeholder="ej., Joshua Bloch"
              value={formData.author}
              onChange={(e) => handleChange("author", e.target.value)}
              error={errors.author}
              required
            />

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Input
                label="Tema / Categoría"
                placeholder="ej., Ciencias de la Computación"
                value={formData.topic}
                onChange={(e) => handleChange("topic", e.target.value)}
                error={errors.topic}
                required
              />

              <Input
                label="Editorial"
                placeholder="ej., Addison-Wesley"
                value={formData.publisher}
                onChange={(e) => handleChange("publisher", e.target.value)}
                error={errors.publisher}
                required
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Input
                label="Género"
                placeholder="ej., Ficción, Ciencia, Historia"
                value={formData.genre}
                onChange={(e) => handleChange("genre", e.target.value)}
                error={errors.genre}
                required
              />

              <Input
                label="Precio"
                placeholder="ej., 29.99"
                value={formData.price}
                onChange={(e) => handleChange("price", e.target.value)}
                error={errors.price}
                required
              />
            </div>
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex justify-end gap-3 mt-6">
          <Button type="button" variant="ghost" onClick={() => navigate("/books")}>
            Cancelar
          </Button>
          <Button type="submit" variant="primary">
            Guardar Libro
          </Button>
        </div>
      </form>
    </div>
  );
}