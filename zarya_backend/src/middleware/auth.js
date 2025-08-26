const jwt = require('jsonwebtoken');
const firebaseConfig = require('../config/firebase');
const logger = require('../utils/logger');

// Verify JWT token and attach user to request
const requireAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Access token required'
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user still exists in database
    const { userId, role } = decoded;
    
    if (role === 'merchant') {
      const merchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, userId);

      if (!merchant) {
        return res.status(401).json({
          error: 'User not found'
        });
      }
      
      // Check if merchant is active
      if (!merchant.isActive) {
        return res.status(401).json({
          error: 'Account is deactivated'
        });
      }

      req.user = {
        ...decoded,
        businessName: merchant.businessName
      };

    } else if (role === 'admin') {
      const admin = await firebaseConfig.getDocument(firebaseConfig.collections.ADMINS, userId);

      if (!admin) {
        return res.status(401).json({
          error: 'User not found'
        });
      }
      
      // Check if admin is active
      if (!admin.isActive) {
        return res.status(401).json({
          error: 'Account is deactivated'
        });
      }

      req.user = {
        ...decoded,
        permissions: admin.permissions
      };

    } else {
      return res.status(401).json({
        error: 'Invalid user role'
      });
    }

    next();

  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      logger.logSecurity('Invalid JWT token', { error: error.message });
      return res.status(401).json({
        error: 'Invalid token'
      });
    } else if (error.name === 'TokenExpiredError') {
      logger.logSecurity('Expired JWT token', { error: error.message });
      return res.status(401).json({
        error: 'Token expired'
      });
    } else {
      logger.logError(error, { middleware: 'requireAuth' });
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }
};

// Require admin role
const requireAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    logger.logSecurity('Unauthorized admin access attempt', { 
      userId: req.user?.userId, 
      role: req.user?.role 
    });
    return res.status(403).json({
      error: 'Admin access required'
    });
  }
  next();
};

// Require specific admin permission
const requirePermission = (permission) => {
  return (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
      logger.logSecurity('Unauthorized admin access attempt', { 
        userId: req.user?.userId, 
        role: req.user?.role 
      });
      return res.status(403).json({
        error: 'Admin access required'
      });
    }

    if (!req.user.permissions || !req.user.permissions.includes(permission)) {
      logger.logSecurity('Insufficient permissions', { 
        userId: req.user.userId, 
        requiredPermission: permission,
        userPermissions: req.user.permissions 
      });
      return res.status(403).json({
        error: `Permission '${permission}' required`
      });
    }

    next();
  };
};

// Require merchant role
const requireMerchant = (req, res, next) => {
  if (!req.user || req.user.role !== 'merchant') {
    logger.logSecurity('Unauthorized merchant access attempt', { 
      userId: req.user?.userId, 
      role: req.user?.role 
    });
    return res.status(403).json({
      error: 'Merchant access required'
    });
  }
  next();
};

// Optional authentication (doesn't fail if no token)
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(); // Continue without authentication
    }

    const token = authHeader.substring(7);

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user still exists in database
    const { userId, role } = decoded;
    
    if (role === 'merchant') {
      const merchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, userId);

      if (merchant && merchant.isActive) {
        req.user = {
          ...decoded,
          businessName: merchant.businessName
        };
      }

    } else if (role === 'admin') {
      const admin = await firebaseConfig.getDocument(firebaseConfig.collections.ADMINS, userId);

      if (admin && admin.isActive) {
        req.user = {
          ...decoded,
          permissions: admin.permissions
        };
      }
    }

    next();

  } catch (error) {
    // Don't fail for optional auth, just continue without user
    next();
  }
};

// Rate limiting for authentication endpoints
const authRateLimit = {
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: {
    error: 'Too many authentication attempts, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
};

// Generate JWT token
const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  });
};

// Verify JWT token without database check
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw error;
  }
};

// Get user from token (for internal use)
const getUserFromToken = async (token) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const { userId, role } = decoded;
    
    if (role === 'merchant') {
      const merchant = await firebaseConfig.getDocument(firebaseConfig.collections.MERCHANTS, userId);

      if (!merchant) {
        throw new Error('User not found');
      }

      return merchant;

    } else if (role === 'admin') {
      const admin = await firebaseConfig.getDocument(firebaseConfig.collections.ADMINS, userId);

      if (!admin) {
        throw new Error('User not found');
      }

      return admin;
    }

    throw new Error('Invalid user role');
  } catch (error) {
    throw error;
  }
};

module.exports = {
  requireAuth,
  requireAdmin,
  requirePermission,
  requireMerchant,
  optionalAuth,
  authRateLimit,
  generateToken,
  verifyToken,
  getUserFromToken
};
