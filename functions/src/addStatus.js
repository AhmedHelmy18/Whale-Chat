const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");
const { FieldValue, Timestamp } = require("firebase-admin/firestore");

exports.addStatus = onCall(async (request) => {
  const {
    type, // 'text' or 'image'
    content, // for text status, this is the text. for image, this is the URL
    caption, // optional caption for image statuses
    backgroundColor, // optional background for text statuses
  } = request.data;
  const userId = request.auth.uid;

  if (!type || !content) {
    throw new HttpsError(
      "invalid-argument",
      "Type and content are required."
    );
  }

  try {
    const userDoc = await admin.firestore().collection("users").doc(userId).get();

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "User not found.");
    }

    const userName = userDoc.data().name || "Unknown";
    const userProfileImage = userDoc.data().image || "";

    const statusItem = {
      id: new Date().getTime().toString(),
      content: content,
      type: type,
      caption: caption || null,
      timestamp: Timestamp.now(),
      viewedBy: [],
      backgroundColor: backgroundColor || null,
    };

    // Check if the user already has a status document created in the last 24 hours
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const statusesRef = admin.firestore().collection("statuses");
    const existingStatusSnapshot = await statusesRef
      .where("userId", "==", userId)
      .where("createdAt", ">", twentyFourHoursAgo)
      .limit(1)
      .get();

    if (!existingStatusSnapshot.empty) {
      // If a status document exists, append the new status item
      const statusDocRef = existingStatusSnapshot.docs[0].ref;
      await statusDocRef.update({
        statusItems: FieldValue.arrayUnion(statusItem),
      });
    } else {
      // Otherwise, create a new status document
      await statusesRef.add({
        userId: userId,
        userName: userName,
        userProfileImage: userProfileImage,
        statusItems: [statusItem],
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    return { success: true };
  } catch (error) {
    logger.error("Error adding status:", error);
    throw new HttpsError("internal", error.message);
  }
});
