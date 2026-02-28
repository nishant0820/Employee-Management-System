require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const connectDB = require('./db');
const logger = require('./logger');

// Initialize Express
const app = express();

// Set up port
const PORT = process.env.PORT || 5000;

// Connect to Database
connectDB();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Setup morgan to use winston for HTTP request logging
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Employee Routes
const employeeRoutes = require('./routes/employeeRoutes');
app.use('/api/employees', employeeRoutes);

// Basic Route
app.get('/', (req, res) => {
  res.send('Employee Management System API Setup complete.');
});

// Create logs directory if it doesn't exist
const fs = require('fs');
const path = require('path');
const logDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir);
}

// Start Server
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});
