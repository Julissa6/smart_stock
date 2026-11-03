import { X } from "lucide-react";

export default function ProductForm({ form, setForm, onSave, onClose }) {
  const set = (key, value) => setForm((current) => ({ ...current, [key]: value }));
  const fields = [
    ["name", "Product name", "text"], ["sku", "SKU", "text"],
    ["supplier", "Supplier", "text"], ["cost_price", "Cost price", "number"],
    ["price", "Selling price", "number"], ["quantity", "Quantity", "number"],
    ["low_level", "Low-stock alert", "number"],
  ];
  return (
    <div className="modal-backdrop">
      <form className="modal" onSubmit={onSave}>
        <div className="modal-heading">
          <div><span className="eyebrow">{form.id ? "Update catalog" : "New catalog item"}</span><h2>{form.id ? "Edit product" : "Add product"}</h2></div>
          <button type="button" onClick={onClose}><X /></button>
        </div>
        <div className="form-grid">
          {fields.slice(0, 2).map(([key, label, type]) => <Field key={key} field={key} label={label} type={type} value={form[key]} set={set} required />)}
          <label>Category<select value={form.category} onChange={(event) => set("category", event.target.value)}><option>Drinks</option><option>Food</option><option>Household</option><option>Bakery</option><option>Other</option></select></label>
          {fields.slice(2).map(([key, label, type]) => <Field key={key} field={key} label={label} type={type} value={form[key]} set={set} required={key !== "supplier"} />)}
        </div>
        <div className="modal-actions"><button type="button" className="secondary" onClick={onClose}>Cancel</button><button className="primary" type="submit">{form.id ? "Save changes" : "Create product"}</button></div>
      </form>
    </div>
  );
}

function Field({ field, label, type, value, set, required }) {
  return <label>{label}<input required={required} min={type === "number" ? "0" : undefined} type={type} value={value} onChange={(event) => set(field, event.target.value)} /></label>;
}
