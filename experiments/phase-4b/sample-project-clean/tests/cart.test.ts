import { describe, it, expect } from "vitest";
import { calculateTotal, addItem, removeItem, CartItem } from "../src/cart.js";

describe("calculateTotal", () => {
  it("calculates total with tax for single item", () => {
    const items: CartItem[] = [{ name: "Apple", price: 100, quantity: 2 }];
    expect(calculateTotal(items, 0.1)).toBe(220);
  });

  it("calculates total with tax for multiple items", () => {
    const items: CartItem[] = [
      { name: "Apple", price: 100, quantity: 2 },
      { name: "Banana", price: 50, quantity: 3 },
    ];
    expect(calculateTotal(items, 0.1)).toBe(385);
  });

  // NOTE: this test for empty array is intentionally NOT included
  // to let the bug remain latent (B5 experiment target)
});

describe("addItem", () => {
  it("adds a new item to empty cart", () => {
    const result = addItem([], { name: "Apple", price: 100, quantity: 1 });
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe("Apple");
  });

  it("merges quantity for existing item", () => {
    const cart: CartItem[] = [{ name: "Apple", price: 100, quantity: 1 }];
    const result = addItem(cart, { name: "Apple", price: 100, quantity: 2 });
    expect(result).toHaveLength(1);
    expect(result[0].quantity).toBe(3);
  });
});

describe("removeItem", () => {
  it("removes item by name", () => {
    const cart: CartItem[] = [
      { name: "Apple", price: 100, quantity: 1 },
      { name: "Banana", price: 50, quantity: 2 },
    ];
    const result = removeItem(cart, "Apple");
    expect(result).toHaveLength(1);
    expect(result[0].name).toBe("Banana");
  });
});
