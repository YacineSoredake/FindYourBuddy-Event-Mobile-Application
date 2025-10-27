const mongoose = require("mongoose");

const swipeSchema = new mongoose.Schema(
  {
    event: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: true,
    },
    swiper: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    target: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    liked: { type: Boolean, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Swipe", swipeSchema);
