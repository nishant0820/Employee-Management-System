const express = require('express');
const router = express.Router();
const { addEmployee } = require('../controllers/employeeController');

// Route to Add employee
router.post('/', addEmployee);

module.exports = router;
