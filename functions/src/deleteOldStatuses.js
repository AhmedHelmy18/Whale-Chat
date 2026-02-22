const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const { admin } = require("./admin");

exports.deleteOldStatuses = onSchedule("every 24 hours", async (event) => {
  logger.info("Running scheduled function to delete old statuses.");

  const now = admin.firestore.Timestamp.now();
  // 24 hours in milliseconds
  const day = 24 * 60 * 60 * 1000;
  const cutoff = new Date(now.toMillis() - day);

  try {
    const oldStatusesSnapshot = await admin
      .firestore()
      .collection("statuses")
      .where("createdAt", "<", cutoff)
      .get();

    if (oldStatusesSnapshot.empty) {
      logger.info("No old statuses to delete.");
      return null;
    }

    // Use a batch to delete all old statuses at once.
    const batch = admin.firestore().batch();
    oldStatusesSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    logger.info(`Successfully deleted ${oldStatusesSnapshot.size} old statuses.`);
    return null;
  } catch (error) {
    logger.error("Error deleting old statuses:", error);
    // Throwing an error ensures that the function execution is marked as failed.
    throw new Error("Failed to delete old statuses.");
  }
});
