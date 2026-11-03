export default function HealthRow({ label, value, total, tone }) {
  const percent = total ? Math.round((value / total) * 100) : 0;
  return (
    <div className="health-row">
      <div><span>{label}</span><strong>{value}</strong></div>
      <div className="bar"><i className={tone} style={{ width: `${percent}%` }} /></div>
      <small>{percent}%</small>
    </div>
  );
}
