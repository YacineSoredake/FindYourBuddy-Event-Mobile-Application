const User = require("../models/User");
const Event = require("../models/Event");
const Buddy = require("../models/Buddy");
const Interest = require("../models/Interested");

exports.fetchUserById = async (req, res) => {
  try {
    const userId = req.params.id;

    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // Count events created by user
    const eventsPostedCount = await Event.countDocuments({ createdBy: userId });

    // Count liked events (assuming user.likedEvents is an array of event IDs)
    const interests = await Interest.find({ user: userId }).populate(
      "event",
      "title category images"
    );

    const likedEvents = interests.map((i) => i.event);

    const matchedBuddiesCount = await Buddy.countDocuments({ users: userId });

    return res.status(200).json({
      success: true,
      data: {
        user,
        stats: {
          eventsPosted: eventsPostedCount,
          matchedBuddies: matchedBuddiesCount,
          likedEventsCount: likedEvents.length,
        },
        likedEvents,
      },
    });
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const updates = req.body;

    const allowedFields = [
      "name",
      "bio",
      "location",
      "avatar",
      "interests",
    ];

    const filteredUpdates = {};
    for (const key of allowedFields) {
      if (updates[key] !== undefined) {
        filteredUpdates[key] = updates[key];
      }
    }

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $set: filteredUpdates },
      { new: true, runValidators: true }
    ).select("-password");

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      user: updatedUser,
    });
  } catch (error) {
    console.error("Update profile error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

