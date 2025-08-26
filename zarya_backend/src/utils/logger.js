const winston = require('winston');
const path = require('path');
const fs = require('fs');

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Define log format
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
    let log = `${timestamp} [${level.toUpperCase()}]: ${message}`;
    
    if (Object.keys(meta).length > 0) {
      log += ` ${JSON.stringify(meta)}`;
    }
    
    if (stack) {
      log += `\n${stack}`;
    }
    
    return log;
  })
);

// Create logger instance
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: logFormat,
  defaultMeta: { service: 'zarya-backend' },
  transports: [
    // Write all logs with level 'error' and below to error.log
    new winston.transports.File({
      filename: path.join(logsDir, 'error.log'),
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    
    // Write all logs with level 'info' and below to combined.log
    new winston.transports.File({
      filename: path.join(logsDir, 'combined.log'),
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    
    // Write all logs with level 'debug' and below to debug.log
    new winston.transports.File({
      filename: path.join(logsDir, 'debug.log'),
      level: 'debug',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
  ],
});

// If we're not in production, log to the console as well
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple(),
      winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
        let log = `${timestamp} [${level}]: ${message}`;
        
        if (Object.keys(meta).length > 0) {
          log += ` ${JSON.stringify(meta)}`;
        }
        
        if (stack) {
          log += `\n${stack}`;
        }
        
        return log;
      })
    )
  }));
}

// Create a stream object for Morgan HTTP logging
logger.stream = {
  write: (message) => {
    logger.info(message.trim());
  },
};

// Helper functions for specific log types
logger.logAPI = (req, res, responseTime) => {
  logger.info('API Request', {
    method: req.method,
    url: req.originalUrl,
    statusCode: res.statusCode,
    responseTime: `${responseTime}ms`,
    userAgent: req.get('User-Agent'),
    ip: req.ip,
    userId: req.user?.id || 'anonymous'
  });
};

logger.logError = (error, context = {}) => {
  logger.error('Application Error', {
    message: error.message,
    stack: error.stack,
    ...context
  });
};

logger.logSecurity = (event, details = {}) => {
  logger.warn('Security Event', {
    event,
    ...details
  });
};

logger.logDatabase = (operation, collection, documentId, details = {}) => {
  logger.info('Database Operation', {
    operation,
    collection,
    documentId,
    ...details
  });
};

logger.logFirebase = (operation, collection, documentId, details = {}) => {
  logger.info('Firebase Operation', {
    operation,
    collection,
    documentId,
    ...details
  });
};

logger.logCloudinary = (operation, publicId, details = {}) => {
  logger.info('Cloudinary Operation', {
    operation,
    publicId,
    ...details
  });
};

logger.logRealtime = (event, room, details = {}) => {
  logger.info('Real-time Event', {
    event,
    room,
    ...details
  });
};

logger.logNotification = (type, recipient, details = {}) => {
  logger.info('Notification Sent', {
    type,
    recipient,
    ...details
  });
};

logger.logPayment = (operation, amount, currency, details = {}) => {
  logger.info('Payment Operation', {
    operation,
    amount,
    currency,
    ...details
  });
};

logger.logCron = (job, status, details = {}) => {
  logger.info('Cron Job', {
    job,
    status,
    ...details
  });
};

// Performance logging
logger.logPerformance = (operation, duration, details = {}) => {
  const level = duration > 1000 ? 'warn' : 'info';
  logger.log(level, 'Performance', {
    operation,
    duration: `${duration}ms`,
    ...details
  });
};

// Audit logging
logger.logAudit = (action, userId, resource, details = {}) => {
  logger.info('Audit Log', {
    action,
    userId,
    resource,
    timestamp: new Date().toISOString(),
    ...details
  });
};

// Health check logging
logger.logHealth = (component, status, details = {}) => {
  const level = status === 'healthy' ? 'info' : 'error';
  logger.log(level, 'Health Check', {
    component,
    status,
    timestamp: new Date().toISOString(),
    ...details
  });
};

// Request/Response logging middleware
logger.requestLogger = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.logAPI(req, res, duration);
  });
  
  next();
};

// Error logging middleware
logger.errorLogger = (error, req, res, next) => {
  logger.logError(error, {
    method: req.method,
    url: req.originalUrl,
    userId: req.user?.id || 'anonymous',
    ip: req.ip
  });
  
  next(error);
};

// Export the logger
module.exports = logger;
