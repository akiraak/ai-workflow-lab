/** User profile */
export interface User {
  id: string;
  name: string;
  email: string;
}

/** In-memory user store */
const users: Map<string, User> = new Map();

/** Register a new user */
export function createUser(id: string, name: string, email: string): User {
  const user: User = { id, name, email };
  users.set(id, user);
  return user;
}

/** Find a user by ID */
export function getUserById(id: string): User | undefined {
  return users.get(id);
}

/** Get all registered users */
export function getAllUsers(): User[] {
  return Array.from(users.values());
}

/** Clear all users (for testing) */
export function clearUsers(): void {
  users.clear();
}
