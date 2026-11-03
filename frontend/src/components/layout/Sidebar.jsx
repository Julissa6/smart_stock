import {
  BarChart3, Boxes, LayoutDashboard, Settings, Truck,
} from "lucide-react";

export default function Sidebar({ page, onNavigate }) {
  return (
    <aside className="sidebar">
      <div className="brand"><Boxes size={26} /><span>SmartStock</span></div>
      <nav>
        <button className={page === "Dashboard" ? "active" : ""} onClick={() => onNavigate("Dashboard")}><LayoutDashboard size={18} /> Dashboard</button>
        <button className={page === "Products" ? "active" : ""} onClick={() => onNavigate("Products")}><Boxes size={18} /> Products</button>
        <button><BarChart3 size={18} /> Reports</button>
        <button><Truck size={18} /> Suppliers</button>
        <button><Settings size={18} /> Settings</button>
      </nav>
      <div className="sidebar-footer">Inventory workspace<br /><small>Web edition</small></div>
    </aside>
  );
}
