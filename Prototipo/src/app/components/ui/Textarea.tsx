import { cn } from "../../lib/utils";

interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {}

export function Textarea({ className, ...props }: TextareaProps) {
  return (
    <textarea
      className={cn(
        "w-full px-3 py-2 border border-gray-300 rounded-lg",
        "focus:outline-none focus:ring-2 focus:ring-[var(--primary)] focus:border-transparent",
        "placeholder:text-gray-400",
        "disabled:bg-gray-100 disabled:cursor-not-allowed",
        "resize-vertical",
        className
      )}
      {...props}
    />
  );
}
