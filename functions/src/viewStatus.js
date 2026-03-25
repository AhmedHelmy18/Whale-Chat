const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");

exports.viewStatus = onCall(async (request) => {
  const { statusId, statusItemId } = request.data;
  const userId = request.auth.uid;

  if (!statusId || !statusItemId) {
    throw new HttpsError(
      "invalid-argument",
      "Status ID and Status Item ID are required."
    );
  }

  try {
    const statusRef = admin.firestore().collection("statuses").doc(statusId);
    const statusDoc = await statusRef.get();

    if (!statusDoc.exists) {
      throw new HttpsError("not-found", "Status not found.");
    }

    const statusData = statusDoc.data();
    const statusItems = statusData.statusItems || [];

    let modified = false;
    const updatedItems = statusItems.map((item) => {
      if (item.id === statusItemId) {
        if (!item.viewedBy || !item.viewedBy.includes(userId)) {
          modified = true;
          return {
            ...item,
            viewedBy: [...(item.viewedBy || []), userId],
          };
        }
      }
      return item;
    });

    if (modified) {
      await statusRef.update({
        statusItems: updatedItems,
      });
    }

    return { success: true };
  } catch (error) {
    logger.error("Error viewing status:", error);
    throw new HttpsError("internal", error.message);
  }
});
