const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");
const { FieldValue } = require("firebase-admin/firestore");

exports.createChat = onCall(async (request) => {
  const { participantId } = request.data;
  const currentUserId = request.auth.uid;

  if (!participantId) {
    throw new HttpsError(
      "invalid-argument",
      "Participant ID is required."
    );
  }

  try {
    // Check if chat already exists (simplified check)
    // In a real app, you might want a more robust "participants" array query
    const snapshot = await admin
      .firestore()
      .collection("chats")
      .where("participants", "array-contains", currentUserId)
      .get();

    let existingChatId = null;

    snapshot.forEach((doc) => {
      const data = doc.data();
      if (data.participants.includes(participantId)) {
        existingChatId = doc.id;
      }
    });

    if (existingChatId) {
      return { chatId: existingChatId, created: false };
    }

    const newChatRef = await admin.firestore().collection("chats").add({
      participants: [currentUserId, participantId],
      createdAt: FieldValue.serverTimestamp(),
      lastMessage: "",
      lastMessageTime: FieldValue.serverTimestamp(),
      lastMessageSenderId: "",
    });

    return { chatId: newChatRef.id, created: true };
  } catch (error) {
    logger.error("Error creating chat:", error);
    throw new HttpsError("internal", error.message);
  }
});
