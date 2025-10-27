const route = require("express").Router();
const AuthContoller = require("../controllers/AuthContoller");
const { verifyAccessToken } = require("../middleware/jwtAuth");
const upload = require("../middleware/multerCloudinary");

// register user
route.post("/register",upload.single('image'), AuthContoller.register);
// login user
route.post("/login", AuthContoller.login);

// get current user data
route.get("/me",verifyAccessToken, AuthContoller.currentUser);

module.exports = route;