const express = require("express");
const router = express.Router();
const buddyController = require("../controllers/BuddyController");

router.post("/request/:eventId", buddyController.requestBuddy);
router.put("/:buddyId/respond", buddyController.respondBuddy);
router.get("/my-requests", buddyController.getMyRequests);
router.get("/event/:eventId", buddyController.getEventBuddies);

module.exports = router;
