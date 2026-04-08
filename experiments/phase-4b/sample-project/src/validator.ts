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

/** Check if an email address is valid (RFC 5322 simplified check) */
export function validateEmail(email: string): boolean {
  if (!isNonEmpty(email)) {
    return false;
  }

  // Check for exactly one @ symbol
  const atIndex = email.indexOf("@");
  if (atIndex === -1 || email.indexOf("@", atIndex + 1) !== -1) {
    return false;
  }

  // Split into local and domain parts
  const localPart = email.substring(0, atIndex);
  const domainPart = email.substring(atIndex + 1);

  // Check local part is not empty
  if (localPart.length === 0) {
    return false;
  }

  // Check domain part is not empty and contains at least one dot
  if (domainPart.length === 0 || !domainPart.includes(".")) {
    return false;
  }

  // Check domain doesn't start or end with dot
  if (domainPart.startsWith(".") || domainPart.endsWith(".")) {
    return false;
  }

  return true;
}
