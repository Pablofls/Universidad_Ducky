import { Search } from "lucide-react";
import { InputHTMLAttributes } from "react";
import { cn } from "../../lib/utils";

interface SearchBarProps extends InputHTMLAttributes<HTMLInputElement> {
  onSearch?: (value: string) => void;
}

export function SearchBar({ className, onSearch, ...props }: SearchBarProps) {
  return (
    <div className="relative">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
      <input
        type="search"
        className={cn(
          "w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg bg-white",
          "focus:outline-none focus:ring-2 focus:ring-[var(--primary)] focus:border-transparent",
          "placeholder:text-gray-400",
          className
        )}
        onChange={(e) => onSearch?.(e.target.value)}
        {...props}
      />
    </div>
  );
}
