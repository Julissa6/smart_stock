const request = async (url, options = {}) => {
  const response = await fetch(url, {
    headers: { 'Content-Type': 'application/json', ...options.headers },
    ...options,
  });
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.message || `Request failed (${response.status})`);
  }
  return response.status === 204 ? null : response.json();
};

export const getProducts = () => request('/api/products');
export const createProduct = (product) => request('/api/products', {
  method: 'POST',
  body: JSON.stringify(product),
});
export const updateProduct = (id, product) => request(`/api/products/${id}`, {
  method: 'PUT',
  body: JSON.stringify(product),
});
export const deleteProduct = (id) => request(`/api/products/${id}`, { method: 'DELETE' });
