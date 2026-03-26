import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Sends an FCM push notification to all active tokens of a user.
 *
 * Responsibilities:
 * - Fetches all tokens from users/{uid}/tokens sub-collection
 * - Sends a multicast message via FCM Admin SDK
 * - Auto-deletes tokens that FCM reports as invalid (not-registered)
 * - Persists the notification to users/{uid}/notifications_history
 *
 * @param uid - The Firebase Auth UID of the recipient
 * @param title - Notification title
 * @param body - Notification body text
 * @param data - Key-value data payload for deep-linking (e.g., { serviceId })
 */
export async function sendNotification(
  uid: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<void> {
  // ── 1. Fetch all FCM tokens for this user ──────────────────────────────────
  const tokensSnapshot = await db.collection(`users/${uid}/tokens`).get();

  if (tokensSnapshot.empty) {
    functions.logger.info(`sendNotification: No tokens found for uid=${uid}`);
    return;
  }

  const tokenDocs = tokensSnapshot.docs;
  const tokens = tokenDocs
    .map((doc: admin.firestore.QueryDocumentSnapshot) => doc.get("token") as string)
    .filter(Boolean);

  if (tokens.length === 0) {
    functions.logger.info(`sendNotification: Token documents exist but no valid token strings for uid=${uid}`);
    return;
  }

  // ── 2. Build and send the multicast message ────────────────────────────────
  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {title, body},
    data,
    android: {
      priority: "high",
      notification: {
        channelId: "high_importance_channel",
        priority: "high",
        defaultSound: true,
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {title, body},
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  let sendResponse: admin.messaging.BatchResponse;
  try {
    sendResponse = await messaging.sendEachForMulticast(message);
    functions.logger.info(
      `sendNotification: sent to uid=${uid}. ` +
      `success=${sendResponse.successCount}, fail=${sendResponse.failureCount}`
    );
  } catch (err) {
    functions.logger.error(`sendNotification: FCM multicast error for uid=${uid}`, err);
    return;
  }

  // ── 3. Auto-delete invalid (not-registered) tokens ────────────────────────
  // FCM docs: invalid tokens return error code messaging/registration-token-not-registered
  const invalidTokenDocs = tokenDocs.filter(
    (_: admin.firestore.QueryDocumentSnapshot, idx: number) => {
    const resp = sendResponse.responses[idx];
    if (resp.success) return false;
    const code = resp.error?.code ?? "";
    return (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    );
  });

  if (invalidTokenDocs.length > 0) {
    const batch = db.batch();
    for (const doc of invalidTokenDocs) {
      functions.logger.info(`sendNotification: deleting stale token ${doc.id} for uid=${uid}`);
      batch.delete(doc.ref);
    }
    await batch.commit();
  }

  // ── 4. Persist notification to history ────────────────────────────────────
  const historyRef = db.collection(`users/${uid}/notifications_history`).doc();
  await historyRef.set({
    title,
    body,
    data,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
