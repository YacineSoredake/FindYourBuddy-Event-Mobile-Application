const express = require("express");
const dotenv = require("dotenv");
const http = require("http");
const { Server } = require("socket.io");
const connectDB = require("./config/db");
const AuthRoute = require("./routes/AuthRoute");
const EventRoute = require("./routes/EventRoute");
const BuddyRoute = require("./routes/BuddyRoute");
const SwipeRoute = require("./routes/SwipeRoute");
const MessageRoute = require("./routes/MessageRoute");
const UserRoute = require("./routes/UserRoute");
const {verifyAccessToken} = require("./middleware/jwtAuth");

dotenv.config();
connectDB();

const Base_URL = "/v1";
const Public_URL = process.env.Public_URL;

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods:["GET","POST"],
  }
});
app.use(express.json()); 
app.use((req, res, next) => {
  req.io = io;
  next();
}); 
app.use(`${Base_URL}/auth`, AuthRoute);
app.use(`${Base_URL}/events`, EventRoute);
app.use(`${Base_URL}/buddies`,verifyAccessToken, BuddyRoute);
app.use(`${Base_URL}/swipes`, verifyAccessToken, SwipeRoute);
app.use(`${Base_URL}/messages`, verifyAccessToken, MessageRoute);
app.use(`${Base_URL}/users`, verifyAccessToken, UserRoute);


require("./socket")(io); 
app.get(`${Base_URL}`, (req, res) => {
  res.send("Backend is running..");
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`🚀 Server running on  ${Public_URL}`));  