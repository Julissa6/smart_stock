import { useEffect, useMemo, useState } from 'react';
import {
  AlertTriangle, BarChart3, Boxes, ChevronDown, DollarSign, LayoutDashboard,
  Menu, PackagePlus, Pencil, Plus, Search, Settings, Trash2, Truck, X,
} from 'lucide-react';
import { createProduct, deleteProduct, getProducts, updateProduct } from './services/api';

const emptyProduct = {
  name: '', sku: '', category: 'Other', supplier: '', cost_price: 0, price: 0,
  quantity: 0, low_level: 5,
};

const money = (value) => new Intl.NumberFormat('en-RW', {
  style: 'currency', currency: 'RWF', maximumFractionDigits: 0,
}).format(value || 0);

function statusOf(product) {
  if (product.quantity <= 0) return 'Out of Stock';
  if (product.quantity <= product.low_level) return 'Low Stock';
  return 'In Stock';
}

function App() {
  const [page, setPage] = useState('Dashboard');
  const [products, setProducts] = useState([]);
  const [search, setSearch] = useState('');
  const [modal, setModal] = useState(null);
  const [form, setForm] = useState(emptyProduct);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  const loadProducts = async () => {
    try {
      setLoading(true);
      setProducts((await getProducts()).data);
      setError('');
    } catch (reason) {
      setError(`Backend unavailable. Start Laravel with “php artisan serve”. ${reason.message}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadProducts(); }, []);

  const filtered = useMemo(() => products.filter((product) =>
    [product.name, product.sku, product.category, product.supplier]
      .join(' ').toLowerCase().includes(search.toLowerCase())), [products, search]);

  const stats = useMemo(() => ({
    total: products.length,
    units: products.reduce((sum, product) => sum + Number(product.quantity), 0),
    low: products.filter((product) => statusOf(product) === 'Low Stock').length,
    out: products.filter((product) => statusOf(product) === 'Out of Stock').length,
    cost: products.reduce((sum, product) => sum + product.cost_price * product.quantity, 0),
    retail: products.reduce((sum, product) => sum + product.price * product.quantity, 0),
  }), [products]);

  const openForm = (product = emptyProduct) => {
    setForm({ ...product });
    setModal('form');
  };

  const saveProduct = async (event) => {
    event.preventDefault();
    try {
      const result = form.id
        ? await updateProduct(form.id, form)
        : await createProduct({ ...form, cost_price: Number(form.cost_price), price: Number(form.price), quantity: Number(form.quantity), low_level: Number(form.low_level) });
      setProducts((current) => form.id
        ? current.map((item) => item.id === form.id ? result.data : item)
        : [result.data, ...current]);
      setModal(null);
      setError('');
    } catch (reason) {
      setError(reason.message);
    }
  };

  const removeProduct = async (product) => {
    if (!window.confirm(`Delete “${product.name}”?`)) return;
    try {
      await deleteProduct(product.id);
      setProducts((current) => current.filter((item) => item.id !== product.id));
    } catch (reason) {
      setError(reason.message);
    }
  };

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand"><Boxes size={26} /><span>SmartStock</span></div>
        <nav>
          <button className={page === 'Dashboard' ? 'active' : ''} onClick={() => setPage('Dashboard')}><LayoutDashboard size={18} /> Dashboard</button>
          <button className={page === 'Products' ? 'active' : ''} onClick={() => setPage('Products')}><Boxes size={18} /> Products</button>
          <button><BarChart3 size={18} /> Reports</button>
          <button><Truck size={18} /> Suppliers</button>
          <button><Settings size={18} /> Settings</button>
        </nav>
        <div className="sidebar-footer">Inventory workspace<br /><small>Web edition</small></div>
      </aside>
      <main className="content">
        <header className="topbar"><button className="mobile-menu"><Menu /></button><div><span className="eyebrow">Inventory management</span><h1>{page}</h1></div><div className="profile">SS</div></header>
        {error && <div className="alert"><AlertTriangle size={18} /> {error}<button onClick={() => setError('')}><X size={15} /></button></div>}
        {page === 'Dashboard'
          ? <Dashboard stats={stats} products={products} onProducts={() => setPage('Products')} />
          : <Products products={filtered} loading={loading} search={search} setSearch={setSearch} openForm={openForm} removeProduct={removeProduct} />}
      </main>
      {modal === 'form' && <ProductForm form={form} setForm={setForm} onSave={saveProduct} onClose={() => setModal(null)} />}
    </div>
  );
}

function Dashboard({ stats, products, onProducts }) {
  return <section className="page">
    <div className="welcome"><div><span className="eyebrow">Overview</span><h2>Good morning, stock manager</h2><p>Here is what is happening with your inventory today.</p></div><button className="primary" onClick={onProducts}><PackagePlus size={17} /> Manage products</button></div>
    <div className="stat-grid">
      <Stat label="Total products" value={stats.total} icon={<Boxes />} tone="blue" />
      <Stat label="Total units" value={stats.units} icon={<PackagePlus />} tone="purple" />
      <Stat label="Cost value" value={money(stats.cost)} icon={<DollarSign />} tone="green" />
      <Stat label="Retail value" value={money(stats.retail)} icon={<BarChart3 />} tone="orange" />
    </div>
    <div className="dashboard-grid"><section className="panel"><div className="panel-heading"><div><span className="eyebrow">Attention required</span><h3>Stock health</h3></div><button className="link" onClick={onProducts}>View all</button></div><div className="health"><Health label="In stock" value={products.filter((p) => statusOf(p) === 'In Stock').length} total={stats.total} tone="green" /><Health label="Low stock" value={stats.low} total={stats.total} tone="orange" /><Health label="Out of stock" value={stats.out} total={stats.total} tone="red" /></div></section><section className="panel"><div className="panel-heading"><div><span className="eyebrow">Quick start</span><h3>Build your inventory</h3></div></div><p className="muted">Add products, set alert levels, and keep your stock accurate from one place.</p><button className="secondary" onClick={onProducts}><Plus size={16} /> Add your first product</button></section></div>
  </section>;
}

function Stat({ label, value, icon, tone }) { return <div className="stat-card"><div className={`stat-icon ${tone}`}>{icon}</div><div><span>{label}</span><strong>{value}</strong></div></div>; }
function Health({ label, value, total, tone }) { const percent = total ? Math.round((value / total) * 100) : 0; return <div className="health-row"><div><span>{label}</span><strong>{value}</strong></div><div className="bar"><i className={tone} style={{ width: `${percent}%` }} /></div><small>{percent}%</small></div>; }

function Products({ products, loading, search, setSearch, openForm, removeProduct }) {
  return <section className="page"><div className="page-heading"><div><span className="eyebrow">Catalog</span><h2>Products</h2><p>Track every item in your stock list.</p></div><button className="primary" onClick={() => openForm()}><Plus size={17} /> Add product</button></div><div className="panel table-panel"><div className="toolbar"><div className="search"><Search size={17} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search products, SKU or category..." /></div><button className="filter"><ChevronDown size={16} /> All products</button></div>{loading ? <div className="empty">Loading products...</div> : products.length === 0 ? <div className="empty"><Boxes size={32} /><h3>No products yet</h3><p>Add your first product to start managing inventory.</p></div> : <div className="table-wrap"><table><thead><tr><th>Product</th><th>SKU</th><th>Category</th><th>Stock</th><th>Price</th><th>Status</th><th /></tr></thead><tbody>{products.map((product) => <tr key={product.id}><td><strong>{product.name}</strong><small>{product.supplier || 'No supplier'}</small></td><td className="mono">{product.sku}</td><td>{product.category}</td><td><strong>{product.quantity}</strong><small>Alert at {product.low_level}</small></td><td>{money(product.price)}</td><td><span className={`badge ${statusOf(product).toLowerCase().replaceAll(' ', '-')}`}>{statusOf(product)}</span></td><td><div className="actions"><button title="Edit" onClick={() => openForm(product)}><Pencil size={15} /></button><button title="Delete" onClick={() => removeProduct(product)}><Trash2 size={15} /></button></div></td></tr>)}</tbody></table></div>}</div></section>;
}

function ProductForm({ form, setForm, onSave, onClose }) {
  const set = (key, value) => setForm((current) => ({ ...current, [key]: value }));
  return <div className="modal-backdrop"><form className="modal" onSubmit={onSave}><div className="modal-heading"><div><span className="eyebrow">{form.id ? 'Update catalog' : 'New catalog item'}</span><h2>{form.id ? 'Edit product' : 'Add product'}</h2></div><button type="button" onClick={onClose}><X /></button></div><div className="form-grid"><label>Product name<input required value={form.name} onChange={(e) => set('name', e.target.value)} /></label><label>SKU<input required value={form.sku} onChange={(e) => set('sku', e.target.value)} /></label><label>Category<select value={form.category} onChange={(e) => set('category', e.target.value)}><option>Drinks</option><option>Food</option><option>Household</option><option>Bakery</option><option>Other</option></select></label><label>Supplier<input value={form.supplier} onChange={(e) => set('supplier', e.target.value)} /></label><label>Cost price<input required min="0" type="number" value={form.cost_price} onChange={(e) => set('cost_price', e.target.value)} /></label><label>Selling price<input required min="0" type="number" value={form.price} onChange={(e) => set('price', e.target.value)} /></label><label>Quantity<input required min="0" type="number" value={form.quantity} onChange={(e) => set('quantity', e.target.value)} /></label><label>Low-stock alert<input required min="0" type="number" value={form.low_level} onChange={(e) => set('low_level', e.target.value)} /></label></div><div className="modal-actions"><button type="button" className="secondary" onClick={onClose}>Cancel</button><button className="primary" type="submit">{form.id ? 'Save changes' : 'Create product'}</button></div></form></div>;
}

export default App;
