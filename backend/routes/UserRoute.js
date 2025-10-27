const express = require("express");
const router = express.Router();
const { fetchUserById } = require("../controllers/UserController");

router.get("/:id", fetchUserById);

module.exports = router;
