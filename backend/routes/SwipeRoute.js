const route = require("express").Router();
const SwipeControlller = require("../controllers/SwiperControlller");

/** 
 @desc Handle swiping action (skip/like)
*/
route.post("/",SwipeControlller.handleSwipe);

/** 
 @desc Get all matches (buddies) for a user
*/
route.get("/matches", SwipeControlller.getUserMatches);

module.exports = route;