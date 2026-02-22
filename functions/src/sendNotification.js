const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin, firebaseAppFCM } = require("./admin");

exports.sendNotification = onCall(async (request) => {
  const userId = request.data.userId;
  const message = request.data.message;

  if (!userId) {
    throw new HttpsError(
      "invalid-argument",
      "User ID is required."
    );
  }

  const userDoc = await admin.firestore().collection("users").doc(userId).get();

  if (!userDoc.exists) {
    throw new HttpsError("not-found", "User not found.");
  }

  const fcmToken = userDoc.get("fcm token");

  logger.log(fcmToken);

  if (fcmToken) {
    if (firebaseAppFCM) {
      try {
        await firebaseAppFCM.messaging().send({
          token: fcmToken,
          notification: {
            title: "You have a new message!",
            body: message,
          },
        });
      } catch (error) {
        logger.error("Error sending notification:", error);
      }
    } else {
      logger.warn(
        "FCM not configured (serviceAccount.json missing), skipping notification."
      );
    }
  }
});
