import { createBrowserRouter } from "react-router";
import { Layout } from "./components/Layout";
import { AppLayout } from "./components/AppLayout";
import { Login } from "./pages/Login";
import { NotFound } from "./pages/NotFound";
import { Dashboard } from "./pages/Dashboard";
import { UserList } from "./pages/users/UserList";
import { UserDetail } from "./pages/users/UserDetail";
import { CreateUser } from "./pages/users/CreateUser";
import { BookList } from "./pages/books/BookList";
import { BookDetail } from "./pages/books/BookDetail";
import { CreateBook } from "./pages/books/CreateBook";
import { EditBook } from "./pages/books/EditBook";
import { CopyList } from "./pages/copies/CopyList";
import { CopyDetail } from "./pages/copies/CopyDetail";
import { CreateCopy } from "./pages/copies/CreateCopy";
import { PurchaseRequestList } from "./pages/purchases/PurchaseRequestList";
import { PurchaseRequestDetail } from "./pages/purchases/PurchaseRequestDetail";
import { CreatePurchaseRequest } from "./pages/purchases/CreatePurchaseRequest";
import { StudentSearch } from "./pages/student/StudentSearch";
import { MobileSearch } from "./pages/student/MobileSearch";
import { PermissionsManagement } from "./pages/permissions/PermissionsManagement";
import { LoansIndex } from "./pages/loans/LoansIndex";
import { ActiveLoans } from "./pages/loans/ActiveLoans";
import { NewLoan } from "./pages/loans/NewLoan";
import { ReturnBook } from "./pages/loans/ReturnBook";
import { Fines } from "./pages/loans/Fines";
import { LoanDetail } from "./pages/loans/LoanDetail";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/app",
    Component: AppLayout,
    children: [
      { index: true, Component: MobileSearch },
      { path: "*", Component: NotFound },
    ],
  },
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: Dashboard },
      { path: "users", Component: UserList },
      { path: "users/create", Component: CreateUser },
      { path: "users/:id", Component: UserDetail },
      { path: "books", Component: BookList },
      { path: "books/create", Component: CreateBook },
      { path: "books/:isbn", Component: BookDetail },
      { path: "books/:isbn/edit", Component: EditBook },
      { path: "copies", Component: CopyList },
      { path: "copies/create", Component: CreateCopy },
      { path: "copies/:id", Component: CopyDetail },
      {
        path: "loans",
        Component: LoansIndex,
        children: [
          { index: true, Component: ActiveLoans },
          { path: "new", Component: NewLoan },
          { path: "return", Component: ReturnBook },
          { path: "fines", Component: Fines },
        ],
      },
      { path: "loans/:id", Component: LoanDetail },
      { path: "loans/:id/renew", Component: LoanDetail },
      { path: "purchases", Component: PurchaseRequestList },
      { path: "purchases/create", Component: CreatePurchaseRequest },
      { path: "purchases/:id", Component: PurchaseRequestDetail },
      { path: "student/search", Component: StudentSearch },
      { path: "permissions", Component: PermissionsManagement },
      { path: "*", Component: NotFound },
    ],
  },
]);