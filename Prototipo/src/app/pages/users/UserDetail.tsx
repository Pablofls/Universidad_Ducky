import { useParams, useNavigate } from "react-router";
import { ArrowLeft, Mail, Calendar, DollarSign } from "lucide-react";
import { mockUsers, mockBorrowedBooks } from "../../data/mockData";
import { Breadcrumb } from "../../components/Breadcrumb";
import { Button } from "../../components/ui/Button";
import { StatusBadge } from "../../components/ui/StatusBadge";
import { Card, CardContent, CardHeader } from "../../components/ui/Card";

export function UserDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const user = mockUsers.find((u) => u.id === id);

  if (!user) {
    return (
      <div className="p-8">
        <p className="text-gray-600">User not found</p>
      </div>
    );
  }

  return (
    <div className="p-8 space-y-6">
      {/* Header */}
      <div>
        <Breadcrumb
          items={[
            { label: "Users", href: "/users" },
            { label: user.name },
          ]}
        />
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm" onClick={() => navigate("/users")}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-gray-900">{user.name}</h1>
              <p className="text-gray-600 mt-1">{user.role} • {user.id}</p>
            </div>
          </div>
          <StatusBadge status={user.status} type="user" />
        </div>
      </div>

      {/* User Profile */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <h3>Profile Information</h3>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-start gap-3">
              <Mail className="h-5 w-5 text-gray-400 mt-0.5" />
              <div>
                <p className="text-sm text-gray-500">Email</p>
                <p className="text-gray-900">{user.email}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Calendar className="h-5 w-5 text-gray-400 mt-0.5" />
              <div>
                <p className="text-sm text-gray-500">Member Since</p>
                <p className="text-gray-900">
                  {new Date(user.createdAt).toLocaleDateString("en-US", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })}
                </p>
              </div>
            </div>
            {user.outstandingFines && user.outstandingFines > 0 && (
              <div className="flex items-start gap-3">
                <DollarSign className="h-5 w-5 text-red-500 mt-0.5" />
                <div>
                  <p className="text-sm text-gray-500">Outstanding Fines</p>
                  <p className="text-red-600 font-medium">
                    ${user.outstandingFines.toFixed(2)}
                  </p>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <h3>Borrowed Books</h3>
                <span className="text-sm text-gray-500">
                  {user.borrowedBooks || 0} active loans
                </span>
              </div>
            </CardHeader>
            <CardContent>
              {mockBorrowedBooks.length > 0 ? (
                <div className="space-y-4">
                  {mockBorrowedBooks.map((book) => (
                    <div
                      key={book.copyId}
                      className="flex items-center justify-between p-4 border border-gray-200 rounded-lg"
                    >
                      <div>
                        <p className="font-medium text-gray-900">{book.bookTitle}</p>
                        <p className="text-sm text-gray-600">Copy ID: {book.copyId}</p>
                        <p className="text-sm text-gray-500 mt-1">
                          Borrowed: {new Date(book.borrowDate).toLocaleDateString()} •
                          Due: {new Date(book.dueDate).toLocaleDateString()}
                        </p>
                      </div>
                      <StatusBadge status={book.status} type="loan" />
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8 text-gray-500">
                  No active loans
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Account Status */}
      <Card>
        <CardHeader>
          <h3>Account Status</h3>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <p className="text-sm text-gray-500 mb-1">Account Status</p>
              <StatusBadge status={user.status} type="user" />
            </div>
            <div>
              <p className="text-sm text-gray-500 mb-1">Total Books Borrowed</p>
              <p className="text-2xl font-semibold text-gray-900">{user.borrowedBooks || 0}</p>
            </div>
            <div>
              <p className="text-sm text-gray-500 mb-1">Outstanding Fines</p>
              <p className={`text-2xl font-semibold ${user.outstandingFines && user.outstandingFines > 0 ? 'text-red-600' : 'text-green-600'}`}>
                ${(user.outstandingFines || 0).toFixed(2)}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
