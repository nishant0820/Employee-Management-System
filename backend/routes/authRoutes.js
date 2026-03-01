const express = require('express');
const router = express.Router();
const { registerUser, loginUser, getUserProfile, updateUserProfile } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// @route   POST /api/auth/register
// @desc    Register a new user (HR, Admin, Employee)
// @access  Public
router.post('/register', registerUser);

// @route   POST /api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', loginUser);

// @route   GET /api/auth/me
// @desc    Get user profile
// @access  Private
router.get('/me', protect, getUserProfile);

// @route   PUT /api/auth/me
// @desc    Update user profile
// @access  Private
router.put('/me', protect, updateUserProfile);

module.exports = router;
