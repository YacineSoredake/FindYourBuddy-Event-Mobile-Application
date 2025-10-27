const Buddy = require("../models/Buddy");
const Message = require("../models/Message");

exports.getChatMessages = async (req, res) => {
  try {
    const { buddyId } = req.params;

    const buddy = await Buddy.findById(buddyId);
    if (!buddy)
      return res
        .status(404)
        .json({ success: false, message: "Buddy not found" });

    if (
      ![buddy.users[0].toString(), buddy.users[1]?.toString()].includes(
        req.user.id
      )
    ) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized" });
    }

    const messages = await Message.find({ buddyId })
      .populate("senderId", "name email avatar")
      .sort({ createdAt: 1 });

    res.status(200).json({ success: true, count: messages.length, messages });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const { buddyId } = req.params;
    const { text } = req.body;

    const buddy = await Buddy.findById(buddyId);
    if (!buddy)
      return res
        .status(404)
        .json({ success: false, message: "Buddy not found" });

    if (
      ![buddy.users[0].toString(), buddy.users[1]?.toString()].includes(
        req.user.id
      )
    ) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized" });
    }

    const message = new Message({
      buddyId,
      senderId: req.user.id,
      text,
    });

    await message.save();

    req.io.to(buddyId).emit("receiveMessage", {
      _id: message._id,
      buddyId,
      senderId: req.user.id,
      text: message.text,
      createdAt: message.createdAt,
    });

    res.status(201).json({ success: true, message });
  } catch (error) {
    console.log(error);

    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};
