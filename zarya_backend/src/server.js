const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const { createServer } = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

// Import configurations
const firebaseConfig = require('./config/firebase');
const cloudinaryConfig = require('./config/cloudinary');
const logger = require('./utils/logger');

// Import middleware
const { errorHandler } = require('./middleware/errorHandler');
const authMiddleware = require('./middleware/auth');
const validationMiddleware = require('./middleware/validation');

// Import routes
const authRoutes = require('./routes/auth');
const merchantRoutes = require('./routes/merchants');
const subscriptionRoutes = require('./routes/subscriptions');
const adminRoutes = require('./routes/admin');
const analyticsRoutes = require('./routes/analytics');
const webhookRoutes = require('./routes/webhooks');

// Import services
const notificationService = require('./services/notificationService');
const cronService = require('./services/cronService');

const app = express();
const server = createServer(app);

// Socket.IO setup for real-time communication
const io = new Server(server, {
  cors: {
    origin: process.env.SOCKET_CORS_ORIGIN || "http://localhost:3000",
    methods: process.env.SOCKET_METHODS?.split(',') || ["GET", "POST"]
  }
});

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Speed limiting
const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 50, // allow 50 requests per 15 minutes, then...
  delayMs: () => 500 // begin adding 500ms of delay per request above 50
});

// Middleware - CORS must come before helmet
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.ALLOWED_ORIGINS?.split(',') || ['https://yourdomain.com']
    : true, // Allow all origins in development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Origin', 'Accept']
}));

app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" },
  contentSecurityPolicy: process.env.NODE_ENV === 'production' ? undefined : false,
}));
app.use(compression());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(limiter);
app.use(speedLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
    version: process.env.APP_VERSION || '1.0.0'
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/merchants', merchantRoutes);
app.use('/api/v1/subscriptions', subscriptionRoutes);
app.use('/api/v1/admin', authMiddleware.requireAuth, authMiddleware.requireAdmin, adminRoutes);
app.use('/api/v1/analytics', authMiddleware.requireAuth, analyticsRoutes);
app.use('/api/v1/webhooks', webhookRoutes);

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);
  
  // Join merchant room if authenticated
  socket.on('join-merchant', (merchantId) => {
    socket.join(`merchant-${merchantId}`);
    logger.info(`Merchant ${merchantId} joined room`);
  });
  
  // Join admin room
  socket.on('join-admin', () => {
    socket.join('admin-room');
    logger.info('Admin joined admin room');
  });
  
  // Handle real-time updates
  socket.on('merchant-update', (data) => {
    socket.to(`merchant-${data.merchantId}`).emit('merchant-updated', data);
    socket.to('admin-room').emit('admin-action', { type: 'merchant-update', data });
  });
  
  socket.on('subscription-update', (data) => {
    socket.to(`merchant-${data.merchantId}`).emit('subscription-updated', data);
    socket.to('admin-room').emit('admin-action', { type: 'subscription-update', data });
  });
  
  socket.on('admin-action', (data) => {
    socket.to('admin-room').emit('admin-action', data);
  });
  
  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
  });
});

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Initialize services
const initializeServices = async () => {
  try {
    // Initialize Firebase
    await firebaseConfig.initialize();
    logger.info('Firebase initialized successfully');
    
    // Initialize default data in Firebase
    await firebaseConfig.initializeDefaultData();
    logger.info('Default data initialized successfully');
    
    // Initialize Cloudinary
    cloudinaryConfig.initialize();
    logger.info('Cloudinary initialized successfully');
    
    // Initialize notification service
    await notificationService.initializeServices();
    logger.info('Notification service initialized successfully');
    
    // Start cron jobs
    cronService.initializeJobs();
    logger.info('Cron jobs initialized successfully');
    
  } catch (error) {
    logger.error('Failed to initialize services:', error);
    process.exit(1);
  }
};

// Graceful shutdown
const gracefulShutdown = (signal) => {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);
  
  server.close(() => {
    logger.info('HTTP server closed');
    
    // Stop cron jobs
    cronService.stopAllJobs();
    logger.info('Cron jobs stopped');
    
    // Close Firebase connections
    firebaseConfig.close();
    logger.info('Firebase connections closed');
    
    process.exit(0);
  });
  
  // Force close after 30 seconds
  setTimeout(() => {
    logger.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 30000);
};

// Handle shutdown signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start server
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await initializeServices();
    
    server.listen(PORT, () => {
      logger.info(`🚀 Zarya Backend Server running on port ${PORT}`);
      logger.info(`📊 Environment: ${process.env.NODE_ENV}`);
      logger.info(`🔗 Health check: http://localhost:${PORT}/health`);
      logger.info(`📚 API Documentation: http://localhost:${PORT}/api/v1/docs`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Start the server
startServer();

module.exports = { app, server, io };
