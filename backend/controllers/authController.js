const User = require('../models/User');
const Employee = require('../models/Employee');
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
    const { fullName, email, company, department, role, phoneNumber, password } = req.body;

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
      phoneNumber,
      department: department || 'HR',
      role: role,
      password,
    });

    if (user) {
      res.status(201).json({
        _id: user.id,
        fullName: user.fullName,
        email: user.email,
        company: user.company,
        department: user.department,
        role: user.role,
        phoneNumber: user.phoneNumber,
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
    const { email, password, department, role } = req.body;

    if (!email || !password || !department) {
      return res.status(400).json({ message: 'Please provide email, password and department' });
    }

    // Check if user exists
    const user = await User.findOne({ email });

    if (user && (await user.comparePassword(password))) {
      // Check department (which is saved under 'role' in DB Schema)
      if (user.department !== department) {
        return res.status(401).json({ message: 'Access denied: Invalid department for this credentials' });
      }

      if (role && user.role && user.role !== role) {
        return res.status(401).json({ message: 'Access denied: Invalid role for this credentials' });
      }
      // Fetch corresponding employee metadata to attach Employee ID
      const employeeData = await Employee.findOne({ email: user.email });

      res.json({
        _id: user.id,
        fullName: user.fullName,
        email: user.email,
        company: user.company,
        department: user.department,
        role: user.role,
        phoneNumber: user.phoneNumber,
        employeeId: employeeData ? employeeData.employeeId : null,
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

// Get user profile
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      const employeeData = await Employee.findOne({ email: user.email });

      res.json({
        _id: user._id,
        fullName: user.fullName,
        email: user.email,
        company: user.company,
        department: user.department,
        role: user.role,
        phoneNumber: user.phoneNumber,
        employeeId: employeeData ? employeeData.employeeId : null,
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Update user profile
exports.updateUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      user.fullName = req.body.fullName || user.fullName;
      user.email = req.body.email || user.email;
      user.phoneNumber = req.body.phoneNumber || user.phoneNumber;

      const updatedUser = await user.save();

      res.json({
        _id: updatedUser._id,
        fullName: updatedUser.fullName,
        email: updatedUser.email,
        company: updatedUser.company,
        department: updatedUser.department,
        role: updatedUser.role,
        phoneNumber: updatedUser.phoneNumber,
        token: generateToken(updatedUser._id),
      });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ message: 'Email already exists' });
    }
    console.error('Error updating profile:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
