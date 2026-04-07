import { CartItem } from "./cart.js";

/** Order status */
export type OrderStatus = "pending" | "confirmed" | "shipped" | "delivered";

/** Order record */
export interface Order {
  id: string;
  userId: string;
  items: CartItem[];
  total: number;
  status: OrderStatus;
  createdAt: Date;
}

/** In-memory order store */
const orders: Map<string, Order> = new Map();

/** Create a new order */
export function createOrder(
  id: string,
  userId: string,
  items: CartItem[],
  total: number
): Order {
  const order: Order = {
    id,
    userId,
    items,
    total,
    status: "pending",
    createdAt: new Date(),
  };
  orders.set(id, order);
  return order;
}

/** Update order status */
export function updateOrderStatus(
  orderId: string,
  status: OrderStatus
): Order | undefined {
  const order = orders.get(orderId);
  if (!order) return undefined;
  const updated = { ...order, status };
  orders.set(orderId, updated);
  return updated;
}

/** Get orders by user ID */
export function getOrdersByUserId(userId: string): Order[] {
  return Array.from(orders.values()).filter((o) => o.userId === userId);
}

/** Clear all orders (for testing) */
export function clearOrders(): void {
  orders.clear();
}
