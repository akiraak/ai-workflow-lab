/** Discount coupon */
export interface Coupon {
  code: string;
  percentage: number; // 0-100
}

/**
 * Apply a percentage discount to a price.
 * Returns the discounted price.
 */
export function applyDiscount(price: number, percentage: number): number {
  if (percentage < 0 || percentage > 100) {
    return price;
  }
  const factor = 1 - percentage / 100;
  return Math.max(0, price * factor);
}

/** Validate that a coupon is well-formed */
export function isValidCoupon(coupon: Coupon): boolean {
  return (
    coupon.code.length > 0 &&
    coupon.percentage >= 0 &&
    coupon.percentage <= 100
  );
}

/** Calculate final price after applying a coupon */
export function calculateDiscountedPrice(
  price: number,
  coupon: Coupon
): number {
  if (!isValidCoupon(coupon)) {
    return price;
  }
  const discounted = applyDiscount(price, coupon.percentage);
  return Math.round(discounted * 100) / 100;
}
