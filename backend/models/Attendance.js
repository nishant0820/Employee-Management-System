const mongoose = require('mongoose');

const attendanceSchema = new mongoose.Schema({
  fullName: { type: String, required: true },
  department: { type: String, required: true },
  role: { type: String, required: true },
  punchIn: { type: Date, required: true },
  punchOut: { type: Date },
  status: { type: String, enum: ['Present', 'Absent', 'Half Day'], default: 'Present' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Attendance', attendanceSchema);
