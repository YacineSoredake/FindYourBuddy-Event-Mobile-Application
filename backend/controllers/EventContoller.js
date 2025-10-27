const Event = require("../models/Event");
const Interest = require("../models/Interested");
const User = require("../models/User");
const Swipe = require("../models/Swipe");

exports.createEvent = async (req, res) => {
  try {
    const { title, category, description, date, location } = req.body;

    if (!title || !category || !description || !date || !location) {
      return res
        .status(400)
        .json({ success: false, message: "All fields are required" });
    }

    if (req.files.length === 0) {
      return res
        .status(400)
        .json({ success: false, message: "At least one image is required" });
    }
    const imageUrls = req.files.map((file) => file.path);

    await Event.create({
      title,
      category,
      description,
      date,
      location: JSON.parse(location),
      images: imageUrls,
      createdBy: req.user.id,
    });

    res.status(201).json({
      success: true,
      message: "Event created successfully",
    });
  } catch (error) {
    console.error("Create Event Error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

exports.markInterest = async (req, res) => {
  const { event_id } = req.body;

  if (!event_id) {
    return res.status(400).json({
      success: false,
      message: "Event ID is required",
    });
  }

  try {
    const user_id = req.user.id;

    const event = await Event.findById(event_id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: "Event not found",
      });
    }

    const alreadyInterested = await Interest.findOne({
      event: event_id,
      user: user_id,
    });
    if (alreadyInterested) {
      return res.status(400).json({
        success: false,
        message: "Already marked as interested",
      });
    }

    await Interest.create({
      event: event_id,
      user: user_id,
    });

    res.status(201).json({
      success: true,
      message: "Interest registered successfully",
    });
  } catch (error) {
    console.error("Interest Event Error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

exports.removeInterest = async (req, res) => {
  try {
    const { event_id } = req.body;
    const userId = req.user.id;

    await Interest.findOneAndDelete({ user: userId, event: event_id });
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

exports.getEvents = async (req, res) => {
  try {
    const { category, location, date, lat, lng } = req.query;
    const userId = req.user ? req.user.id : null;
    let filter = {};

    // Filters
    if (category) filter.category = category;

    if (location)
      filter["location.address"] = { $regex: location, $options: "i" };

    if (lat && lng) {
      filter["location.lat"] = parseFloat(lat);
      filter["location.lng"] = parseFloat(lng);
    }

    if (date) {
      const start = new Date(date);
      const end = new Date(date);
      end.setHours(23, 59, 59, 999);
      filter.date = { $gte: start, $lte: end };
    }

    // Find events
    const events = await Event.find(filter)
      .populate("createdBy", "name email")
      .sort({ date: 1 });

    // Enrich each event with interest info
    const eventsWithInterest = await Promise.all(
      events.map(async (event) => {
        const interestedCount = await Interest.countDocuments({
          event: event._id,
        });

        let isInterested = false;
        if (userId) {
          const existingInterest = await Interest.findOne({
            event: event._id,
            user: userId,
          });
          isInterested = !!existingInterest;
        }

        return {
          ...event.toObject(),
          isInterested,
          interestedCount,
        };
      })
    );

    res.status(200).json({
      success: true,
      count: eventsWithInterest.length,
      events: eventsWithInterest,
    });
  } catch (error) {
    console.error("Get Events Error:", error.message);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

exports.SharedInterest = async (req, res) => {
  try {
    const userId = req.user.id;

    // 1️⃣ Get user's interests
    const myInterests = await Interest.find({ user: userId }).select("event");
    if (!myInterests.length) {
      return res.status(200).json({
        success: true,
        message: "User has no interest",
        data: [],
      });
    }

    const myEventIds = myInterests.map((i) => i.event.toString());

    // 2️⃣ Get already swiped users
    const swiped = await Swipe.find({ swiper: userId }).select("target");
    const swipedUserIds = swiped.map((s) => s.target.toString());

    // 3️⃣ Find shared interests excluding swiped users
    const sharedInterests = await Interest.find({
      $and: [
        { event: { $in: myEventIds } },
        { user: { $ne: userId } },
        { user: { $nin: swipedUserIds } },
      ],
    }).populate("user event");

    // 4Build the buddies list
    const buddiesMap = new Map();

    for (const interest of sharedInterests) {
      const buddy = interest.user;

      if (!buddiesMap.has(buddy._id.toString())) {
        buddiesMap.set(buddy._id.toString(), {
          _id: buddy._id,
          name: buddy.name,
          avatar: buddy.avatar,
          bio: buddy.bio,
          fields: buddy.fields,
          sharedEvents: [],
          sharedEventCount: 0,
        });
      }

      const buddyData = buddiesMap.get(buddy._id.toString());
      buddyData.sharedEvents.push({
        eventId: interest.event._id,
        title: interest.event.title,
        category: interest.event.category,
        date: interest.event.date,
      });
      buddyData.sharedEventCount++;
    }

    const buddies = Array.from(buddiesMap.values()).sort(
      (a, b) => b.sharedEventCount - a.sharedEventCount
    );

    res.status(200).json({
      success: true,
      count: buddies.length,
      data: buddies,
    });
  } catch (error) {
    console.error(" Error fetching buddies with shared interests:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Get all events a user is interested in
exports.getUserInterests = async (req, res) => {
  try {
    const userId = req.user.id;
    const interests = await Interest.find({ user: userId }).populate("event");
    res
      .status(200)
      .json({ success: true, events: interests.map((i) => i.event) });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};
