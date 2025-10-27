const mongoose = require("mongoose");

const Interest = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    event: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: true,
    },
  },
  { timestamps: true }
);

// prevent duplicate interests
Interest.index({ user: 1, event: 1 }, { unique: true });

module.exports = mongoose.model("Interest", Interest);
