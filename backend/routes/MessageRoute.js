const route = require("express").Router();
const MessageContoller = require("../controllers/MessageContoller");

route.get("/:buddyId", MessageContoller.getChatMessages);
route.post("/:buddyId", MessageContoller.sendMessage);

module.exports = route;