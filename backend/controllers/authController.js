const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'secret_key_12345', {
    expiresIn: '30d',
  });
};

// Register new user
exports.registerUser = async (req, res) => {
  try {
    const { fullName, email, company, role, password } = req.body;

    if (!fullName || !email || !company || !password) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Check if user already exists
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Create user
    const user = await User.create({
      fullName,
      email,
      company,
      role: role || 'HR',
      password,
    });

    if (user) {
      res.status(201).json({
        _id: user.id,
        fullName: user.fullName,
        email: user.email,
        company: user.company,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      res.status(400).json({ message: 'Invalid user data' });
    }
  } catch (error) {
    console.error('Error in registerUser:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Login user
exports.loginUser = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({ message: 'Please provide email, password and role' });
    }

    // Check if user exists
    const user = await User.findOne({ email });

    if (user && (await user.comparePassword(password))) {
      // Check role
      if (user.role !== role) {
        return res.status(401).json({ message: 'Access denied: Invalid role for this credentials' });
      }

      res.json({
        _id: user.id,
        fullName: user.fullName,
        email: user.email,
        company: user.company,
        role: user.role,
        token: generateToken(user._id),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    console.error('Error in loginUser:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
