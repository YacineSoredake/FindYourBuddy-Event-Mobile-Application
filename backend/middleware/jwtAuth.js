const jwt = require("jsonwebtoken");

exports.verifyAccessToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader ? authHeader.split(" ")[1] : null;

  if (!token) {
    return res.status(401).json({ message: "Access token required" });
  }

  try {
    const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    req.user = {
      id: decoded.userId,
    };

    next();
  } catch (error) {
    const msg =
      error.name === "TokenExpiredError"
        ? "Token expired"
        : "Invalid or unauthorized token";

    return res.status(401).json({
      message: msg,
      error: error.message,
    });
  }
};
