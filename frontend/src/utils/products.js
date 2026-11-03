export const emptyProduct = {
  name: "",
  sku: "",
  category: "Other",
  supplier: "",
  cost_price: 0,
  price: 0,
  quantity: 0,
  low_level: 5,
};

export const money = (value) =>
  new Intl.NumberFormat("en-RW", {
    style: "currency",
    currency: "RWF",
    maximumFractionDigits: 0,
  }).format(value || 0);

export const statusOf = (product) => {
  if (product.quantity <= 0) return "Out of Stock";
  if (product.quantity <= product.low_level) return "Low Stock";
  return "In Stock";
};
