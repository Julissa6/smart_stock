import { AlertTriangle, X } from "lucide-react";

export default function ErrorAlert({ message, onClose }) {
  if (!message) return null;
  return (
    <div className="alert">
      <AlertTriangle size={18} /> {message}
      <button onClick={onClose}><X size={15} /></button>
    </div>
  );
}
