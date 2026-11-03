import { Boxes, ChevronDown, Pencil, Plus, Search, Trash2 } from "lucide-react";
import { money, statusOf } from "../utils/products";

export default function ProductsPage({ products, loading, search, setSearch, openForm, removeProduct }) {
  return (
    <section className="page"><div className="page-heading"><div><span className="eyebrow">Catalog</span><h2>Products</h2><p>Track every item in your stock list.</p></div><button className="primary" onClick={() => openForm()}><Plus size={17} /> Add product</button></div>
      <div className="panel table-panel"><div className="toolbar"><div className="search"><Search size={17} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search products, SKU or category..." /></div><button className="filter"><ChevronDown size={16} /> All products</button></div>
        {loading ? <div className="empty">Loading products...</div> : products.length === 0 ? <div className="empty"><Boxes size={32} /><h3>No products yet</h3><p>Add your first product to start managing inventory.</p></div> : <div className="table-wrap"><table><thead><tr><th>Product</th><th>SKU</th><th>Category</th><th>Stock</th><th>Price</th><th>Status</th><th /></tr></thead><tbody>{products.map((product) => <tr key={product.id}><td><strong>{product.name}</strong><small>{product.supplier || "No supplier"}</small></td><td className="mono">{product.sku}</td><td>{product.category}</td><td><strong>{product.quantity}</strong><small>Alert at {product.low_level}</small></td><td>{money(product.price)}</td><td><span className={`badge ${statusOf(product).toLowerCase().replaceAll(" ", "-")}`}>{statusOf(product)}</span></td><td><div className="actions"><button title="Edit" onClick={() => openForm(product)}><Pencil size={15} /></button><button title="Delete" onClick={() => removeProduct(product)}><Trash2 size={15} /></button></div></td></tr>)}</tbody></table></div>}
      </div>
    </section>
  );
}
