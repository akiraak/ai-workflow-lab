/** Shopping cart item */
export interface CartItem {
  name: string;
  price: number;
  quantity: number;
}

/**
 * Calculate the total price of items in the cart.
 * Applies tax rate to the subtotal.
 */
export function calculateTotal(items: CartItem[], taxRate: number = 0.1): number {
  if (items.length === 0) return 0;
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  return Math.round(subtotal * (1 + taxRate) * 100) / 100;
}

/** Add an item to the cart, merging quantity if it already exists */
export function addItem(cart: CartItem[], newItem: CartItem): CartItem[] {
  const existing = cart.find((item) => item.name === newItem.name);
  if (existing) {
    return cart.map((item) =>
      item.name === newItem.name
        ? { ...item, quantity: item.quantity + newItem.quantity }
        : item
    );
  }
  return [...cart, newItem];
}

/** Remove an item from the cart by name */
export function removeItem(cart: CartItem[], name: string): CartItem[] {
  return cart.filter((item) => item.name !== name);
}
