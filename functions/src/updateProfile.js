const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");

exports.updateProfile = onCall(async (request) => {
  const { name, about, image } = request.data;
  const userId = request.auth.uid;

  try {
    const updateData = {};
    if (name) updateData.name = name;
    if (about) updateData.about = about;
    if (image) updateData.image = image;

    if (Object.keys(updateData).length > 0) {
      await admin.firestore().collection("users").doc(userId).update(updateData);
    }

    if (name) {
      await admin.auth().updateUser(userId, { displayName: name });
    }

    return { success: true };
  } catch (error) {
    logger.error("Error updating profile:", error);
    throw new HttpsError("internal", error.message);
  }
});
