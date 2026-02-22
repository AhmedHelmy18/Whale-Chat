const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");
const { FieldValue } = require("firebase-admin/firestore");

exports.updateMessageStatus = onCall(async (request) => {
  const { chatId, status } = request.data;
  const userId = request.auth.uid;

  if (!chatId || !status) {
    throw new HttpsError(
      "invalid-argument",
      "Chat ID and status are required."
    );
  }

  if (!["delivered", "seen"].includes(status)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid status. Must be 'delivered' or 'seen'."
    );
  }

  try {
    const messagesRef = admin
      .firestore()
      .collection("chats")
      .doc(chatId)
      .collection("messages");

    let query = messagesRef.where("senderId", "!=", userId);

    if (status === "delivered") {
      query = query.where("status", "==", "sent");
    } else if (status === "seen") {
      query = query.where("status", "in", ["sent", "delivered"]);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      return { success: true, updatedCount: 0 };
    }

    const batch = admin.firestore().batch();

    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {
        status: status,
        readAt: status === "seen" ? FieldValue.serverTimestamp() : null,
      });
    });

    await batch.commit();

    return { success: true, updatedCount: snapshot.size };
  } catch (error) {
    logger.error("Error updating message status:", error);
    throw new HttpsError("internal", error.message);
  }
});
