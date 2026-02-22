const { sendNotification } = require("./src/sendNotification");
const { createAccount } = require("./src/createAccount");
const { sendMessage } = require("./src/sendMessage");
const { createChat } = require("./src/createChat");
const { updateProfile } = require("./src/updateProfile");
const { updateMessageStatus } = require("./src/updateMessageStatus");
const { addStatus } = require("./src/addStatus");
const { deleteOldStatuses } = require("./src/deleteOldStatuses");

module.exports = {
  sendNotification,
  createAccount,
  sendMessage,
  createChat,
  updateProfile,
  updateMessageStatus,
  addStatus,
  deleteOldStatuses,
};
