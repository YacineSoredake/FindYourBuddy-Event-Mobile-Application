const jwt = require("jsonwebtoken");

const signAccessToken = async (id) => {
  const payload = {
    userId: id,
  };

  const secret = process.env.ACCESS_TOKEN_SECRET;
  const options = {
    expiresIn: process.env.JWT_EXPIRES_IN,
    issuer: "auth-service",
    audience: "event-app",
  };

  return jwt.sign(payload, secret, options);
};

const signRefreshToken = async (id) => {
  const payload = {
    userId: id,
  };

  const secret = process.env.REFRESH_TOKEN_SECRET;
  const options = {
    expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN,
    issuer: "auth-service",
    audience: "event-app",
  };

  return jwt.sign(payload, secret, options);
};

// Function to verify refresh tokens
const verifyRefreshToken = async (refToken) => {
  if (!refToken) {
    console.log("ref token empty");
  }
  return new Promise((resolve, reject) => {
    jwt.verify(refToken, process.env.REFRESH_TOKEN_SECRET, (err, payload) => {
      if (err) {
        return reject(err);
      }
      const userID = payload.userId;
      resolve(userID);
    });
  });
};

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
};
