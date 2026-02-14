/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest, onCall} = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const admin = require("firebase-admin")
const { FieldValue } = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

if (process.env.FUNCTIONS_EMULATOR) {
    process.env.FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099";
    process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";
}

admin.initializeApp();

let serviceAccount;
try {
    serviceAccount = require("./serviceAccount.json");
} catch (e) {
    logger.warn("serviceAccount.json not found, FCM notifications might not work.");
}

let firebaseAppFCM;
if (serviceAccount) {
    firebaseAppFCM = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    }, "fcmApp");
} 

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
            if (firebaseAppFCM) {
                try {
                    await firebaseAppFCM.messaging().send({
                        token: fcmToken,
                        notification: {
                            title: "You have a new message!",
                            body: message
                        }
                    });
                } catch (error) {
                    logger.error("Error sending notification:", error);
                }
            } else {
                logger.warn("FCM not configured (serviceAccount.json missing), skipping notification.");
            }
        }
    }
});

exports.createAccount = onCall(async (request) => {
    const { email, password, name } = request.data;

    if (!email || !password || !name) {
        throw new functions.https.HttpsError("invalid-argument", "Email, password, and name are required.");
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
        throw new functions.https.HttpsError("internal", error.message);
    }
});

exports.sendMessage = onCall(async (request) => {
    const { chatId, content, type, imageUrls } = request.data;
    const senderId = request.auth.uid;

    if (!chatId || !type) {
        throw new functions.https.HttpsError("invalid-argument", "Chat ID and type are required.");
    }

    try {
        const messageData = {
            senderId: senderId,
            content: content || "",
            type: type,
            sentAt: FieldValue.serverTimestamp(),
            readAt: null,
            status: 'sent',
            imageUrls: imageUrls || [],
        };

        await admin.firestore().collection("chats").doc(chatId).collection("messages").add(messageData);

        let lastMessagePreview = content;
        if (type === 'image' || (imageUrls && imageUrls.length > 0)) {
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
        throw new functions.https.HttpsError("internal", error.message);
    }
});

exports.createChat = onCall(async (request) => {
    const { participantId } = request.data;
    const currentUserId = request.auth.uid;

    if (!participantId) {
        throw new functions.https.HttpsError("invalid-argument", "Participant ID is required.");
    }

    try {
        // Check if chat already exists (simplified check)
        // In a real app, you might want a more robust "participants" array query
        const snapshot = await admin.firestore().collection("chats")
            .where("participants", "array-contains", currentUserId)
            .get();

        let existingChatId = null;

        snapshot.forEach(doc => {
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
        throw new functions.https.HttpsError("internal", error.message);
    }
});

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
        throw new functions.https.HttpsError("internal", error.message);
    }
});

exports.updateMessageStatus = onCall(async (request) => {
    const { chatId, status } = request.data;
    const userId = request.auth.uid;

    if (!chatId || !status) {
        throw new functions.https.HttpsError("invalid-argument", "Chat ID and status are required.");
    }

    if (!['delivered', 'seen'].includes(status)) {
        throw new functions.https.HttpsError("invalid-argument", "Invalid status. Must be 'delivered' or 'seen'.");
    }

    try {
        const messagesRef = admin.firestore().collection("chats").doc(chatId).collection("messages");
        
        let query = messagesRef.where('senderId', '!=', userId); 
        
        if (status === 'delivered') {
             query = query.where('status', '==', 'sent');
        } else if (status === 'seen') {
             query = query.where('status', 'in', ['sent', 'delivered']);
        }
        
        const snapshot = await query.get();
        
        if (snapshot.empty) {
            return { success: true, updatedCount: 0 };
        }

        const batch = admin.firestore().batch();
        
        snapshot.docs.forEach(doc => {
            batch.update(doc.ref, { status: status, readAt: status === 'seen' ? FieldValue.serverTimestamp() : null });
        });

        await batch.commit();

        return { success: true, updatedCount: snapshot.size };
    } catch (error) {
        logger.error("Error updating message status:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});