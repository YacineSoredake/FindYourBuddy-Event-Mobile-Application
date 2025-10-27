const Buddy = require("../models/Buddy");

// Request a buddy for an event
exports.requestBuddy = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { accepterId } = req.body;

    if (accepterId === req.user.id) {
      return res
        .status(400)
        .json({ success: false, message: "You cannot request yourself" });
    }

    const buddyRequest = new Buddy({
      eventId,
      requesterId: req.user.id,
      accepterId,
      status: "pending",
    });

    await buddyRequest.save();

    res
      .status(201)
      .json({ success: true, message: "Buddy request sent", buddyRequest });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};
// Respond to buddy request (accept/decline)
exports.respondBuddy = async (req, res) => {
  try {
    const { buddyId } = req.params;
    const { action } = req.body; // "accepted" or "declined"

    if (!["accepted", "declined"].includes(action)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid action" });
    }

    const request = await Buddy.findById(buddyId);
    if (!request) {
      return res
        .status(404)
        .json({ success: false, message: "Request not found" });
    }

    if (request.accepterId.toString() !== req.user.id) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized" });
    }

    request.status = action;
    await request.save();

    res.json({ success: true, message: `Buddy request ${action}`, request });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};

// Get my buddy requests (sent & received)
exports.getMyRequests = async (req, res) => {
  try {
    const requests = await Buddy.find({
      $or: [{ requesterId: req.user.id }, { accepterId: req.user.id }],
    })
      .populate("eventId", "title date")
      .populate("requesterId", "name email")
      .populate("accepterId", "name email")
      .sort({ createdAt: -1 });

    res.json({ success: true, count: requests.length, requests });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};

// Get all accepted buddies for an event
exports.getEventBuddies = async (req, res) => {
  try {
    const { eventId } = req.params;
    const buddies = await Buddy.find({ eventId, status: "accepted" })
      .populate("requesterId", "name email")
      .populate("accepterId", "name email");

    res.json({ success: true, count: buddies.length, buddies });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};
