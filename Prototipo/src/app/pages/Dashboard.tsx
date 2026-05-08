import { Card, CardContent, CardHeader } from "../components/ui/Card";
import { Book, BookCopy, BookOpen, AlertCircle } from "lucide-react";
import { mockDashboardStats } from "../data/mockData";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from "recharts";

const categoryData = [
  { id: "cs", name: "Ciencias de la Computación", value: 35 },
  { id: "se", name: "Ingeniería de Software", value: 25 },
  { id: "db", name: "Sistemas de Bases de Datos", value: 15 },
  { id: "it", name: "Gestión de TI", value: 10 },
  { id: "other", name: "Otros", value: 15 },
];

const loanTrendData = [
  { id: "oct", month: "Oct", loans: 45 },
  { id: "nov", month: "Nov", loans: 52 },
  { id: "dic", month: "Dic", loans: 38 },
  { id: "ene", month: "Ene", loans: 61 },
  { id: "feb", month: "Feb", loans: 55 },
  { id: "mar", month: "Mar", loans: 48 },
];

const COLORS = ["#3b82f6", "#10b981", "#f59e0b", "#8b5cf6", "#6b7280"];

export function Dashboard() {
  const stats = mockDashboardStats;

  return (
    <div className="p-8 space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-gray-900 mb-2">Tablero de Control</h1>
        <p className="text-gray-600">Bienvenido al Sistema de Gestión Ducky</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 mb-1">Total de Libros</p>
                <p className="text-3xl font-semibold text-gray-900">{stats.totalBooks}</p>
              </div>
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <Book className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 mb-1">Total de Ejemplares</p>
                <p className="text-3xl font-semibold text-gray-900">{stats.totalCopies}</p>
              </div>
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <BookCopy className="h-6 w-6 text-green-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 mb-1">Préstamos Activos</p>
                <p className="text-3xl font-semibold text-gray-900">{stats.activeLoans}</p>
              </div>
              <div className="w-12 h-12 bg-amber-100 rounded-lg flex items-center justify-center">
                <BookOpen className="h-6 w-6 text-amber-600" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600 mb-1">Libros Vencidos</p>
                <p className="text-3xl font-semibold text-gray-900">{stats.overdueBooks}</p>
              </div>
              <div className="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                <AlertCircle className="h-6 w-6 text-red-600" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Loan Trends */}
        <Card>
          <CardHeader>
            <h3>Tendencia de Préstamos</h3>
            <p className="text-sm text-gray-600">Actividad mensual de préstamos</p>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={loanTrendData}>
                <CartesianGrid key="grid" strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis key="xaxis" dataKey="month" stroke="#6b7280" />
                <YAxis key="yaxis" stroke="#6b7280" />
                <Tooltip key="tooltip" />
                <Bar key="bar" dataKey="loans" fill="#3b82f6" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Category Distribution */}
        <Card>
          <CardHeader>
            <h3>Categorías de Libros</h3>
            <p className="text-sm text-gray-600">Distribución por tema</p>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  key="pie"
                  data={categoryData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {categoryData.map((entry, index) => (
                    <Cell key={`cell-${entry.id}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip key="tooltip" />
                <Legend key="legend" />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}