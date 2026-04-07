/** Notification record */
export interface Notification {
  to: string;
  subject: string;
  body: string;
  sentAt: Date;
}

/** Sent notifications log (in-memory, for testing) */
const sentNotifications: Notification[] = [];

/** Send a notification (stub: just logs to in-memory store) */
export function sendNotification(
  to: string,
  subject: string,
  body: string
): Notification {
  const notification: Notification = {
    to,
    subject,
    body,
    sentAt: new Date(),
  };
  sentNotifications.push(notification);
  return notification;
}

/** Get all sent notifications (for testing) */
export function getSentNotifications(): Notification[] {
  return [...sentNotifications];
}

/** Clear notification log (for testing) */
export function clearNotifications(): void {
  sentNotifications.length = 0;
}
