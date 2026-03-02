const Attendance = require('../models/Attendance');
const logger = require('../logger');

// @desc    Punch in for attendance
// @route   POST /api/attendance/punch-in
// @access  Public (or protected depending on auth middleware)
const punchIn = async (req, res) => {
  try {
    const { fullName, department, role } = req.body;

    if (!fullName || !department || !role) {
      return res.status(400).json({ message: 'Please provide fullName, department, and role' });
    }

    // Optional: check if there's already an active punch-in without punch-out
    const existing = await Attendance.findOne({ fullName, punchOut: null });
    if (existing) {
      return res.status(400).json({ message: 'User is already punched in.' });
    }

    const attendance = await Attendance.create({
      fullName,
      department,
      role,
      punchIn: new Date(),
    });

    res.status(201).json(attendance);
  } catch (error) {
    logger.error(`Punch In Error: ${error.message}`);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Punch out for attendance
// @route   POST /api/attendance/punch-out
// @access  Public
const punchOut = async (req, res) => {
  try {
    const { fullName } = req.body;

    if (!fullName) {
      return res.status(400).json({ message: 'Please provide fullName' });
    }

    const attendance = await Attendance.findOne({ fullName, punchOut: null }).sort({ punchIn: -1 });

    if (!attendance) {
      return res.status(404).json({ message: 'No active punch-in found for this user.' });
    }

    attendance.punchOut = new Date();

    // Calculate hours worked
    const diffMs = attendance.punchOut - attendance.punchIn;
    const diffHours = diffMs / (1000 * 60 * 60);

    // Rules for attendance status
    if (diffHours >= 9) {
      attendance.status = 'Present';
    } else {
      attendance.status = 'Half Day';
    }

    await attendance.save();

    res.status(200).json(attendance);
  } catch (error) {
    logger.error(`Punch Out Error: ${error.message}`);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Get all attendance records
// @route   GET /api/attendance
// @access  Public
const getAttendance = async (req, res) => {
  try {
    const records = await Attendance.find({}).sort({ createdAt: -1 });
    res.status(200).json(records);
  } catch (error) {
    logger.error(`Get Attendance Error: ${error.message}`);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  punchIn,
  punchOut,
  getAttendance,
};
