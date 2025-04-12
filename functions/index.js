/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest, onCall} = require("firebase-functions/v2/https");
const admin = require("firebase-admin")
const logger = require("firebase-functions/logger");

if (process.env.FUNCTIONS_EMULATOR) {
    process.env.FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099";
    process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";

    admin.initializeApp();
}
const serviceAccount = require("./serviceAccount.json");
const firebaseAppFCM = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
}, "fcmApp"); 

exports.sendNotification = onCall(async function (request) {

    const userId = request.data.userId;
    const message = request.data.message;

    if (!userId) {
        throw new functions.https.HttpsError("invalid-argument", "User ID is required.");
    }
    else {
        const userDoc = await admin.firestore().collection("users").doc(userId).get();

        if (!userDoc.exists) {
            throw new functions.https.HttpsError("not-found", "User not found.");
        }

        const fcmToken = userDoc.get("fcm token");

        logger.log(fcmToken);

        if (fcmToken) {
            firebaseAppFCM.messaging().send({
                token: fcmToken,
                notification: {
                    title: "You have a new message!",
                    body: message
                }
            })
        }
    }
});