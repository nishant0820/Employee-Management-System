const express = require('express');
const router = express.Router();
const { punchIn, punchOut, getAttendance } = require('../controllers/attendanceController');

// @route   POST /api/attendance/punch-in
router.post('/punch-in', punchIn);

// @route   POST /api/attendance/punch-out
router.post('/punch-out', punchOut);

// @route   GET /api/attendance
router.get('/', getAttendance);

module.exports = router;
