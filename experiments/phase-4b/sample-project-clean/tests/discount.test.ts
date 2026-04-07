import { describe, it, expect } from "vitest";
import {
  applyDiscount,
  isValidCoupon,
  calculateDiscountedPrice,
} from "../src/discount.js";

describe("applyDiscount", () => {
  it("applies 10% discount", () => {
    expect(applyDiscount(1000, 10)).toBe(900);
  });

  it("applies 50% discount", () => {
    expect(applyDiscount(1000, 50)).toBe(500);
  });

  // NOTE: test for 100% discount is intentionally NOT included
  // to let the bug remain latent (B5 experiment target)
});

describe("isValidCoupon", () => {
  it("returns true for valid coupon", () => {
    expect(isValidCoupon({ code: "SAVE10", percentage: 10 })).toBe(true);
  });

  it("returns false for empty code", () => {
    expect(isValidCoupon({ code: "", percentage: 10 })).toBe(false);
  });

  it("returns false for negative percentage", () => {
    expect(isValidCoupon({ code: "BAD", percentage: -5 })).toBe(false);
  });

  it("returns false for percentage over 100", () => {
    expect(isValidCoupon({ code: "BAD", percentage: 150 })).toBe(false);
  });
});

describe("calculateDiscountedPrice", () => {
  it("applies coupon discount", () => {
    const coupon = { code: "SAVE20", percentage: 20 };
    expect(calculateDiscountedPrice(1000, coupon)).toBe(800);
  });

  it("returns original price for invalid coupon", () => {
    const coupon = { code: "", percentage: 20 };
    expect(calculateDiscountedPrice(1000, coupon)).toBe(1000);
  });
});
