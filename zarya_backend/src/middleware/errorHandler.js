const logger = require('../utils/logger');

// Custom error class
class AppError extends Error {
  constructor(message, statusCode, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    Error.captureStackTrace(this, this.constructor);
  }
}

// Error handler middleware
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  logger.logError(err, {
    method: req.method,
    url: req.originalUrl,
    userId: req.user?.userId || 'anonymous',
    ip: req.ip
  });

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new AppError(message, 404);
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    const message = `Duplicate field value: ${field}`;
    error = new AppError(message, 400);
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = new AppError(message, 400);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const message = 'Invalid token';
    error = new AppError(message, 401);
  }

  if (err.name === 'TokenExpiredError') {
    const message = 'Token expired';
    error = new AppError(message, 401);
  }

  // Firebase errors
  if (err.code === 'auth/user-not-found') {
    const message = 'User not found';
    error = new AppError(message, 404);
  }

  if (err.code === 'auth/wrong-password') {
    const message = 'Invalid credentials';
    error = new AppError(message, 401);
  }

  if (err.code === 'auth/email-already-in-use') {
    const message = 'Email already in use';
    error = new AppError(message, 409);
  }

  // Cloudinary errors
  if (err.http_code === 400) {
    const message = 'Invalid file format or size';
    error = new AppError(message, 400);
  }

  if (err.http_code === 401) {
    const message = 'Cloudinary authentication failed';
    error = new AppError(message, 500);
  }

  // Rate limiting errors
  if (err.status === 429) {
    const message = 'Too many requests, please try again later';
    error = new AppError(message, 429);
  }

  // Network errors
  if (err.code === 'ECONNREFUSED') {
    const message = 'Service temporarily unavailable';
    error = new AppError(message, 503);
  }

  if (err.code === 'ETIMEDOUT') {
    const message = 'Request timeout';
    error = new AppError(message, 408);
  }

  // Default error
  if (!error.statusCode) {
    error.statusCode = 500;
    error.message = 'Internal server error';
  }

  // Send error response
  res.status(error.statusCode).json({
    success: false,
    error: error.message,
    ...(process.env.NODE_ENV === 'development' && {
      stack: error.stack,
      details: err
    })
  });
};

// 404 handler
const notFound = (req, res, next) => {
  const error = new AppError(`Route not found: ${req.originalUrl}`, 404);
  next(error);
};

// Async error wrapper
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Validation error handler
const handleValidationError = (err) => {
  const errors = Object.values(err.errors).map(val => val.message);
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new AppError(message, 400);
};

// JWT error handler
const handleJWTError = () => {
  return new AppError('Invalid token. Please log in again!', 401);
};

const handleJWTExpiredError = () => {
  return new AppError('Your token has expired! Please log in again.', 401);
};

// Cast error handler
const handleCastErrorDB = (err) => {
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, 400);
};

// Duplicate field error handler
const handleDuplicateFieldsDB = (err) => {
  const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0];
  const message = `Duplicate field value: ${value}. Please use another value!`;
  return new AppError(message, 400);
};

// Production error handler
const sendErrorProd = (err, res) => {
  // Operational, trusted error: send message to client
  if (err.isOperational) {
    res.status(err.statusCode).json({
      success: false,
      error: err.message
    });
  } else {
    // Programming or other unknown error: don't leak error details
    logger.logError(err);
    res.status(500).json({
      success: false,
      error: 'Something went wrong!'
    });
  }
};

// Development error handler
const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    success: false,
    error: err.message,
    err,
    stack: err.stack
  });
};

// Global error handler
const globalErrorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, res);
  } else if (process.env.NODE_ENV === 'production') {
    let error = { ...err };
    error.message = err.message;

    if (error.name === 'CastError') error = handleCastErrorDB(error);
    if (error.code === 11000) error = handleDuplicateFieldsDB(error);
    if (error.name === 'ValidationError') error = handleValidationError(error);
    if (error.name === 'JsonWebTokenError') error = handleJWTError();
    if (error.name === 'TokenExpiredError') error = handleJWTExpiredError();

    sendErrorProd(error, res);
  }
};

// Unhandled promise rejection handler
const handleUnhandledRejection = (err) => {
  logger.logError(err, { type: 'Unhandled Promise Rejection' });
  process.exit(1);
};

// Uncaught exception handler
const handleUncaughtException = (err) => {
  logger.logError(err, { type: 'Uncaught Exception' });
  process.exit(1);
};

module.exports = {
  AppError,
  errorHandler,
  notFound,
  asyncHandler,
  globalErrorHandler,
  handleUnhandledRejection,
  handleUncaughtException
};
