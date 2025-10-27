const User = require("../models/User");
const bcrypt = require("bcryptjs");
const { signAccessToken, signRefreshToken } = require("../helpers/jwt");

exports.register = async (req, res) => {
  const { email, password, name, fields } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res
        .status(409)
        .json({ success: false, message: "User already exists" });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    imageUrl = req.file.path;
    if (!imageUrl) {
      return res
        .status(400)
        .json({ success: false, message: "Your image is required" });
    }

    const newUser = new User({
      email,
      name,
      fields,
      password: hashedPassword,
      avatar: imageUrl,
    });

    const savedUser = await newUser.save();
    const accessToken = await signAccessToken(savedUser._id);
    const refreshToken = await signRefreshToken(savedUser._id);

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      user: {
        id: savedUser._id,
        name: savedUser.name,
        email: savedUser.email,
        fields: savedUser.fields,
        avatar: imageUrl,
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(401)
        .json({ success: false, message: "Invalid email or password" });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res
        .status(401)
        .json({ success: false, message: "Invalid email or password" });
    }
    const accessToken = await signAccessToken(user._id);
    const refreshToken = await signRefreshToken(user._id);
    res.status(200).json({
      success: true,
      message: "Login successful",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        fields: user.fields,
        avatar:user.avatar
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

exports.currentUser = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findById(userId).select("-password");
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
