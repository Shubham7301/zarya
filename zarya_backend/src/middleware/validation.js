const { validationResult } = require('express-validator');
const logger = require('../utils/logger');

// Middleware to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(error => ({
      field: error.path,
      message: error.msg,
      value: error.value
    }));

    logger.logInfo('Validation failed', {
      path: req.path,
      method: req.method,
      errors: errorMessages
    });

    return res.status(400).json({
      error: 'Validation failed',
      details: errorMessages
    });
  }
  
  next();
};

// Custom validation helpers
const isValidPhoneNumber = (value) => {
  const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
  return phoneRegex.test(value);
};

const isValidEmail = (value) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(value);
};

const isValidPassword = (value) => {
  // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
  const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/;
  return passwordRegex.test(value);
};

const isValidDate = (value) => {
  const date = new Date(value);
  return date instanceof Date && !isNaN(date);
};

const isValidTime = (value) => {
  const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
  return timeRegex.test(value);
};

const isValidPrice = (value) => {
  const price = parseFloat(value);
  return !isNaN(price) && price >= 0;
};

const isValidDuration = (value) => {
  const duration = parseInt(value);
  return !isNaN(duration) && duration > 0 && duration <= 480; // Max 8 hours
};

// Export validation helpers
module.exports = {
  handleValidationErrors,
  isValidPhoneNumber,
  isValidEmail,
  isValidPassword,
  isValidDate,
  isValidTime,
  isValidPrice,
  isValidDuration
};
