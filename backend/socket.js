const Message = require("./models/Message");

function initSocket(io) {
  console.log("Socket.io initialized");
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    socket.on("joinBuddyChat", (buddyId) => {
      socket.join(buddyId);
    });

    socket.on("sendMessage", async ({ buddyId, senderId, text }) => {
      const message = await Message.create({ buddyId, senderId, text });

      socket.to(buddyId).emit("receiveMessage", message);
    });

    socket.on("disconnect", () => {
      console.log("User disconnected:", socket.id);
    });
  });
}

module.exports = initSocket;
