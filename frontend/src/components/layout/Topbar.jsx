import { Menu } from "lucide-react";

export default function Topbar({ page }) {
  return (
    <header className="topbar">
      <button className="mobile-menu"><Menu /></button>
      <div><span className="eyebrow">Inventory management</span><h1>{page}</h1></div>
      <div className="profile">SS</div>
    </header>
  );
}
