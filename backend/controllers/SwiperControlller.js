const Swipe = require("../models/Swipe");
const Buddy = require("../models/Buddy");

exports.handleSwipe = async (req, res) => {
  try {
    const { eventId, targetId, liked } = req.body;
    const userId = req.user.id;

    if (!eventId || !targetId || typeof liked !== "boolean") {
      return res
        .status(400)
        .json({ success: false, message: "Missing or invalid fields" });
    }

    if (userId === targetId) {
      return res.status(400).json({
        success: false,
        message: "Duhh ? You cannot swipe yourself.",
      });
    }

    const existing = await Swipe.findOne({
      event: eventId,
      swiper: userId,
      target: targetId,
    });

    if (existing) {
      existing.liked = liked;
      await existing.save();
      return res.status(200).json({
        success: true,
        status: "updated",
        message: "Swipe updated",
        swipe: existing,
      });
    }

    const newSwipe = await Swipe.create({
      event: eventId,
      swiper: userId,
      target: targetId,
      liked,
    });

    // If liked, check for mutual like
    if (liked) {
      const mutual = await Swipe.findOne({
        event: eventId,
        swiper: targetId,
        target: userId,
        liked: true,
      });

      if (mutual) {
        const existingBuddy = await Buddy.findOne({
          event: eventId,
          users: { $all: [userId, targetId] },
        });

        if (!existingBuddy) {
          const newBuddy = await Buddy.create({
            event: eventId,
            users: [userId, targetId],
          });

          return res.status(201).json({
            success: true,
            status: "match",
            message: "It's a match!",
            buddy: newBuddy,
            swipe: newSwipe,
          });
        }
      }
    }

    return res.status(201).json({
      success: true,
      status: "recorded",
      message: "Swipe recorded",
      swipe: newSwipe,
    });
  } catch (error) {
    console.error("Error handling swipe:", error);
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
};

exports.getUserMatches = async (req, res) => {
  try {
    const userId = req.user.id;

    const buddies = await Buddy.find({ users: userId })
      .populate("users", "name email avatar")
      .lean();

    // Remove the current user from each buddy’s "users" array
    const filtered = buddies.map((buddy) => {
      const otherUser = buddy.users.find(
        (u) => u._id.toString() !== userId.toString()
      );
      return { ...buddy, otherUser };
    });

    res.status(200).json({
      success: true,
      message: "matched buddies fetched",
      buddies: filtered,
    });
  } catch (error) {
    console.error("Error fetching matches:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};
