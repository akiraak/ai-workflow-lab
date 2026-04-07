/**
 * Input validation utilities.
 * New validators will be added here during experiments.
 */

/** Check if a string is non-empty after trimming */
export function isNonEmpty(value: string): boolean {
  return value.trim().length > 0;
}

/** Check if a number is positive */
export function isPositive(value: number): boolean {
  return value > 0;
}

/** Check if a number is within a range (inclusive) */
export function isInRange(value: number, min: number, max: number): boolean {
  return value >= min && value <= max;
}
