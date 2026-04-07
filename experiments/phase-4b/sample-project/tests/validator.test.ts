import { describe, it, expect } from "vitest";
import { isNonEmpty, isPositive, isInRange } from "../src/validator.js";

describe("isNonEmpty", () => {
  it("returns true for non-empty string", () => {
    expect(isNonEmpty("hello")).toBe(true);
  });

  it("returns false for empty string", () => {
    expect(isNonEmpty("")).toBe(false);
  });

  it("returns false for whitespace-only string", () => {
    expect(isNonEmpty("   ")).toBe(false);
  });
});

describe("isPositive", () => {
  it("returns true for positive number", () => {
    expect(isPositive(1)).toBe(true);
  });

  it("returns false for zero", () => {
    expect(isPositive(0)).toBe(false);
  });

  it("returns false for negative number", () => {
    expect(isPositive(-1)).toBe(false);
  });
});

describe("isInRange", () => {
  it("returns true for value within range", () => {
    expect(isInRange(5, 1, 10)).toBe(true);
  });

  it("returns true for value at boundaries", () => {
    expect(isInRange(1, 1, 10)).toBe(true);
    expect(isInRange(10, 1, 10)).toBe(true);
  });

  it("returns false for value outside range", () => {
    expect(isInRange(0, 1, 10)).toBe(false);
    expect(isInRange(11, 1, 10)).toBe(false);
  });
});
