const Employee = require('../models/Employee');
const logger = require('../logger');

// @desc    Add a new employee
// @route   POST /api/employees
// @access  Public
const addEmployee = async (req, res) => {
  try {
    if (!req.body) {
      return res.status(400).json({ message: 'Invalid data format. Please make sure Content-Type is set to application/json.' });
    }
    
    const { fullName, email, phone, employeeId, department, role, status } = req.body;

    // Fast validation according to front-end fields requirement
    if (!fullName || !email || !phone || !employeeId || !department || !role) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Check if employee already exists by email
    const emailExists = await Employee.findOne({ email });
    if (emailExists) {
      return res.status(400).json({ message: 'An employee with this email already exists' });
    }

    // Check if employee already exists by employeeId
    const idExists = await Employee.findOne({ employeeId });
    if (idExists) {
      return res.status(400).json({ message: 'An employee with this Employee ID already exists' });
    }

    const employee = await Employee.create({
      fullName,
      email,
      phone,
      employeeId,
      department,
      role,
      status: status || 'Active', // Sets default if not provided
    });

    if (employee) {
      logger.info(`New employee added: ${employee.employeeId}`);
      res.status(201).json({
        _id: employee._id,
        fullName: employee.fullName,
        email: employee.email,
        phone: employee.phone,
        employeeId: employee.employeeId,
        department: employee.department,
        role: employee.role,
        status: employee.status,
      });
    } else {
      res.status(400).json({ message: 'Invalid employee data received' });
    }
  } catch (error) {
    logger.error(`Add Employee Error: ${error.message}`);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  addEmployee,
};
