const route = require("express").Router();
const EventContoller = require("../controllers/EventContoller");
const { verifyAccessToken } = require("../middleware/jwtAuth");
const upload = require("../middleware/multerCloudinary");

// Create Event
route.post("/", verifyAccessToken, upload.array("images", 5), EventContoller.createEvent);

// Mark or remove interest
route.post("/interest", verifyAccessToken, EventContoller.markInterest);
route.delete("/interest", verifyAccessToken, EventContoller.removeInterest);

//Explore shared interests people
route.get("/explore", verifyAccessToken, EventContoller.SharedInterest);

//Get all events
route.get("/", verifyAccessToken, EventContoller.getEvents);

module.exports = route;
