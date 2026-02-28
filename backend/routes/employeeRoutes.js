const express = require('express');
const router = express.Router();
const { addEmployee, getEmployees } = require('../controllers/employeeController');

// Route to Add employee
router.post('/', addEmployee);

// Route to Get all employees
router.get('/', getEmployees);

module.exports = router;
