const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");
const { FieldValue } = require("firebase-admin/firestore");

exports.createAccount = onCall(async (request) => {
  const { email, password, name } = request.data;

  if (!email || !password || !name) {
    throw new HttpsError(
      "invalid-argument",
      "Email, password, and name are required."
    );
  }

  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: name,
    });

    await admin.firestore().collection("users").doc(userRecord.uid).set({
      email: email,
      name: name,
      id: userRecord.uid,
      about: "Hey there! I am using Whale Chat.",
      image: "",
      createdAt: FieldValue.serverTimestamp(),
      lastActive: FieldValue.serverTimestamp(),
      isOnline: false,
      pushToken: "",
    });

    return { uid: userRecord.uid };
  } catch (error) {
    logger.error("Error creating account:", error);
    throw new HttpsError("internal", error.message);
  }
});
