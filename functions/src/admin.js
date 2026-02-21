const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

if (admin.apps.length === 0) {
    if (process.env.FUNCTIONS_EMULATOR) {
        process.env.FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099";
        process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";
    }
    admin.initializeApp();
}

let firebaseAppFCM;
if (!admin.apps.find(app => app.name === 'fcmApp')) {
    try {
        const serviceAccount = require("../serviceAccount.json");
        firebaseAppFCM = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        }, "fcmApp");
    } catch (e) {
        logger.warn("serviceAccount.json not found, FCM notifications might not work.");
    }
} else {
    firebaseAppFCM = admin.app('fcmApp');
}

module.exports = { admin, firebaseAppFCM };
