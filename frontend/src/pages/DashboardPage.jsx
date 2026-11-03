import { BarChart3, Boxes, DollarSign, PackagePlus, Plus } from "lucide-react";
import StatCard from "../components/dashboard/StatCard";
import HealthRow from "../components/dashboard/HealthRow";
import { money, statusOf } from "../utils/products";

export default function DashboardPage({ stats, products, onProducts }) {
  return (
    <section className="page">
      <div className="welcome"><div><span className="eyebrow">Overview</span><h2>Good morning, stock manager</h2><p>Here is what is happening with your inventory today.</p></div><button className="primary" onClick={onProducts}><PackagePlus size={17} /> Manage products</button></div>
      <div className="stat-grid">
        <StatCard label="Total products" value={stats.total} icon={<Boxes />} tone="blue" />
        <StatCard label="Total units" value={stats.units} icon={<PackagePlus />} tone="purple" />
        <StatCard label="Cost value" value={money(stats.cost)} icon={<DollarSign />} tone="green" />
        <StatCard label="Retail value" value={money(stats.retail)} icon={<BarChart3 />} tone="orange" />
      </div>
      <div className="dashboard-grid">
        <section className="panel"><div className="panel-heading"><div><span className="eyebrow">Attention required</span><h3>Stock health</h3></div><button className="link" onClick={onProducts}>View all</button></div><div className="health"><HealthRow label="In stock" value={products.filter((p) => statusOf(p) === "In Stock").length} total={stats.total} tone="green" /><HealthRow label="Low stock" value={stats.low} total={stats.total} tone="orange" /><HealthRow label="Out of stock" value={stats.out} total={stats.total} tone="red" /></div></section>
        <section className="panel"><div className="panel-heading"><div><span className="eyebrow">Quick start</span><h3>Build your inventory</h3></div></div><p className="muted">Add products, set alert levels, and keep your stock accurate from one place.</p><button className="secondary" onClick={onProducts}><Plus size={16} /> Add your first product</button></section>
      </div>
    </section>
  );
}
