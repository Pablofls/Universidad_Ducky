import { CopyStatus, UserStatus, PurchaseRequestStatus } from "../../types";
import { cn } from "../../lib/utils";

interface StatusBadgeProps {
  status: CopyStatus | UserStatus | PurchaseRequestStatus | string;
  type?: "copy" | "user" | "loan" | "purchase";
}

export function StatusBadge({ status, type = "copy" }: StatusBadgeProps) {
  const getStatusStyles = () => {
    if (type === "copy") {
      const copyStatus = status as CopyStatus;
      switch (copyStatus) {
        case "Available":
          return "bg-green-100 text-green-800 border-green-200";
        case "Loaned":
          return "bg-amber-100 text-amber-800 border-amber-200";
        case "Reserved":
          return "bg-blue-100 text-blue-800 border-blue-200";
        case "Internal Use":
          return "bg-gray-100 text-gray-800 border-gray-200";
        default:
          return "bg-gray-100 text-gray-800 border-gray-200";
      }
    }

    if (type === "user") {
      const userStatus = status as UserStatus;
      switch (userStatus) {
        case "Active":
          return "bg-green-100 text-green-800 border-green-200";
        case "Inactive":
          return "bg-gray-100 text-gray-800 border-gray-200";
        case "Suspended":
          return "bg-red-100 text-red-800 border-red-200";
        default:
          return "bg-gray-100 text-gray-800 border-gray-200";
      }
    }

    if (type === "loan") {
      switch (status) {
        case "Active":
          return "bg-green-100 text-green-800 border-green-200";
        case "Overdue":
          return "bg-red-100 text-red-800 border-red-200";
        default:
          return "bg-gray-100 text-gray-800 border-gray-200";
      }
    }

    if (type === "purchase") {
      const purchaseStatus = status as PurchaseRequestStatus;
      switch (purchaseStatus) {
        case "Pending":
          return "bg-amber-100 text-amber-800 border-amber-200";
        case "Approved":
          return "bg-green-100 text-green-800 border-green-200";
        case "Rejected":
          return "bg-red-100 text-red-800 border-red-200";
        case "Purchased":
          return "bg-blue-100 text-blue-800 border-blue-200";
        default:
          return "bg-gray-100 text-gray-800 border-gray-200";
      }
    }

    return "bg-gray-100 text-gray-800 border-gray-200";
  };

  const getStatusLabel = () => {
    if (type === "copy") {
      const copyStatus = status as CopyStatus;
      switch (copyStatus) {
        case "Available":
          return "Disponible";
        case "Loaned":
          return "Prestado";
        case "Reserved":
          return "Reservado";
        case "Internal Use":
          return "Uso Interno";
        default:
          return status;
      }
    }

    if (type === "user") {
      const userStatus = status as UserStatus;
      switch (userStatus) {
        case "Active":
          return "Activo";
        case "Inactive":
          return "Inactivo";
        case "Suspended":
          return "Suspendido";
        default:
          return status;
      }
    }

    if (type === "loan") {
      switch (status) {
        case "Active":
          return "Activo";
        case "Overdue":
          return "Vencido";
        default:
          return status;
      }
    }

    if (type === "purchase") {
      const purchaseStatus = status as PurchaseRequestStatus;
      switch (purchaseStatus) {
        case "Pending":
          return "Pendiente";
        case "Approved":
          return "Aprobado";
        case "Rejected":
          return "Rechazado";
        case "Purchased":
          return "Comprado";
        default:
          return status;
      }
    }

    return status;
  };

  return (
    <span
      className={cn(
        "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border",
        getStatusStyles()
      )}
    >
      {getStatusLabel()}
    </span>
  );
}