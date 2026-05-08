import { ReactNode } from "react";
import { CheckCircle, AlertCircle, Info, XCircle } from "lucide-react";
import { cn } from "../../lib/utils";

interface AlertProps {
  variant: "success" | "error" | "warning" | "info";
  children: ReactNode;
  className?: string;
}

export function Alert({ variant, children, className }: AlertProps) {
  const variants = {
    success: {
      container: "bg-green-50 border-green-200 text-green-800",
      icon: <CheckCircle className="h-5 w-5 text-green-600" />,
    },
    error: {
      container: "bg-red-50 border-red-200 text-red-800",
      icon: <XCircle className="h-5 w-5 text-red-600" />,
    },
    warning: {
      container: "bg-amber-50 border-amber-200 text-amber-800",
      icon: <AlertCircle className="h-5 w-5 text-amber-600" />,
    },
    info: {
      container: "bg-blue-50 border-blue-200 text-blue-800",
      icon: <Info className="h-5 w-5 text-blue-600" />,
    },
  };

  const { container, icon } = variants[variant];

  return (
    <div className={cn("flex items-start gap-3 p-4 border rounded-lg", container, className)}>
      <div className="flex-shrink-0 mt-0.5">{icon}</div>
      <div className="flex-1">{children}</div>
    </div>
  );
}
