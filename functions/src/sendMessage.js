const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");
const { FieldValue } = require("firebase-admin/firestore");

exports.sendMessage = onCall(async (request) => {
  const { chatId, content, type, imageUrls } = request.data;
  const senderId = request.auth.uid;

  if (!chatId || !type) {
    throw new HttpsError(
      "invalid-argument",
      "Chat ID and type are required."
    );
  }

  try {
    const messageData = {
      senderId: senderId,
      content: content || "",
      type: type,
      sentAt: FieldValue.serverTimestamp(),
      readAt: null,
      status: "sent",
      imageUrls: imageUrls || [],
    };

    await admin
      .firestore()
      .collection("chats")
      .doc(chatId)
      .collection("messages")
      .add(messageData);

    let lastMessagePreview = content;
    if (type === "image" || (imageUrls && imageUrls.length > 0)) {
      lastMessagePreview = content ? "📷 Photo + Message" : "📷 Photo";
    }

    await admin.firestore().collection("chats").doc(chatId).update({
      lastMessage: lastMessagePreview,
      lastMessageTime: FieldValue.serverTimestamp(),
      lastMessageSenderId: senderId,
    });

    return { success: true };
  } catch (error) {
    logger.error("Error sending message:", error);
    throw new HttpsError("internal", error.message);
  }
});
