const mongoose = require('mongoose');
const logger = require('./logger');

const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI;
    if (!uri) {
      throw new Error("MONGO_URI is not defined in the environment variables.");
    }
    const conn = await mongoose.connect(uri);
    console.log('db connected');
    logger.info(`db connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('db connection failed');
    logger.error(`db connection failed: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
