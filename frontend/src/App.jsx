import { useEffect, useMemo, useState } from "react";
import {
  createProduct,
  deleteProduct,
  getProducts,
  updateProduct,
} from "./services/api";
import Sidebar from "./components/layout/Sidebar";
import Topbar from "./components/layout/Topbar";
import ErrorAlert from "./components/feedback/ErrorAlert";
import ProductForm from "./components/products/ProductForm";
import DashboardPage from "./pages/DashboardPage";
import ProductsPage from "./pages/ProductsPage";
import { emptyProduct, statusOf } from "./utils/products";

function App() {
  const [page, setPage] = useState("Dashboard");
  const [products, setProducts] = useState([]);
  const [search, setSearch] = useState("");
  const [modal, setModal] = useState(null);
  const [form, setForm] = useState(emptyProduct);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  const loadProducts = async () => {
    try {
      setLoading(true);
      setProducts((await getProducts()).data);
      setError("");
    } catch (reason) {
      setError(
        `Backend unavailable. Start Laravel with “php artisan serve”. ${reason.message}`,
      );
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProducts();
  }, []);

  const filtered = useMemo(
    () =>
      products.filter((product) =>
        [product.name, product.sku, product.category, product.supplier]
          .join(" ")
          .toLowerCase()
          .includes(search.toLowerCase()),
      ),
    [products, search],
  );

  const stats = useMemo(
    () => ({
      total: products.length,
      units: products.reduce((sum, product) => sum + Number(product.quantity), 0),
      low: products.filter((product) => statusOf(product) === "Low Stock").length,
      out: products.filter((product) => statusOf(product) === "Out of Stock").length,
      cost: products.reduce((sum, product) => sum + product.cost_price * product.quantity, 0),
      retail: products.reduce((sum, product) => sum + product.price * product.quantity, 0),
    }),
    [products],
  );

  const openForm = (product = emptyProduct) => {
    setForm({ ...product });
    setModal("form");
  };

  const saveProduct = async (event) => {
    event.preventDefault();
    try {
      const payload = {
        ...form,
        cost_price: Number(form.cost_price),
        price: Number(form.price),
        quantity: Number(form.quantity),
        low_level: Number(form.low_level),
      };
      const result = form.id
        ? await updateProduct(form.id, payload)
        : await createProduct(payload);
      setProducts((current) =>
        form.id
          ? current.map((item) => (item.id === form.id ? result.data : item))
          : [result.data, ...current],
      );
      setModal(null);
      setError("");
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
      <Sidebar page={page} onNavigate={setPage} />
      <main className="content">
        <Topbar page={page} />
        <ErrorAlert message={error} onClose={() => setError("")} />
        {page === "Dashboard" ? (
          <DashboardPage
            stats={stats}
            products={products}
            onProducts={() => setPage("Products")}
          />
        ) : (
          <ProductsPage
            products={filtered}
            loading={loading}
            search={search}
            setSearch={setSearch}
            openForm={openForm}
            removeProduct={removeProduct}
          />
        )}
      </main>
      {modal === "form" && (
        <ProductForm
          form={form}
          setForm={setForm}
          onSave={saveProduct}
          onClose={() => setModal(null)}
        />
      )}
    </div>
  );
}

export default App;
