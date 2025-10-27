const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema({
  buddyId: { type: mongoose.Schema.Types.ObjectId, ref: "Buddy", required: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  text: { type: String, required: true },
  read: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model("Message", messageSchema);
