import * as functions from "firebase-functions";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {sendNotification} from "../notifications/sendNotification";

/**
 * Firestore trigger: fires whenever a document in the `services` collection is updated.
 *
 * Anti-spam rule: only proceeds if `status` actually changed.
 * Notification targets: the worker identified by `workerId` in the service doc.
 * Data payload: includes `serviceId` for client-side deep-linking.
 */
export const onServiceStatusChange = onDocumentUpdated(
  "services/{serviceId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) {
      functions.logger.warn("onServiceStatusChange: missing before/after data");
      return;
    }

    const beforeStatus = before.status as string;
    const afterStatus = after.status as string;
    const workerId = after.workerId as string;
    const serviceId = event.params.serviceId;

    // ── Anti-spam: do nothing if status didn't change ──────────────────────
    if (beforeStatus === afterStatus) {
      functions.logger.info(
        `onServiceStatusChange: status unchanged (${afterStatus}) for service=${serviceId}, skipping`
      );
      return;
    }

    functions.logger.info(
      `onServiceStatusChange: service=${serviceId}, ${beforeStatus} → ${afterStatus}, worker=${workerId}`
    );

    // ── Determine message content based on new status ──────────────────────
    let title: string;
    let body: string;

    switch (afterStatus) {
    case "active":
      title = "¡Servicio Aprobado! 🎉";
      body = "Tu servicio fue aprobado y ya está visible para todos los clientes.";
      break;
    case "rejected":
      title = "Servicio Rechazado";
      body = after.adminNotes
        ? `Tu servicio fue rechazado. Motivo: ${after.adminNotes}`
        : "Tu servicio fue rechazado. Revisa las notas del administrador.";
      break;
    default:
      // Status changed to something else (e.g., pending_review); no notification needed.
      functions.logger.info(`onServiceStatusChange: unhandled status "${afterStatus}", skipping`);
      return;
    }

    // ── Send the notification with serviceId in the data payload ───────────
    await sendNotification(workerId, title, body, {serviceId});
  }
);
