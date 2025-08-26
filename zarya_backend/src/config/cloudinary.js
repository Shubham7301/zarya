const cloudinary = require('cloudinary').v2;
const logger = require('../utils/logger');

let isInitialized = false;

const initialize = () => {
  try {
    if (isInitialized) {
      logger.info('Cloudinary already initialized');
      return;
    }

    // Configure Cloudinary
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true
    });

    isInitialized = true;
    logger.info('Cloudinary initialized successfully');
    
  } catch (error) {
    logger.error('Failed to initialize Cloudinary:', error);
    throw error;
  }
};

// Upload image to Cloudinary
const uploadImage = async (file, options = {}) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const uploadOptions = {
      folder: options.folder || 'zarya/uploads',
      resource_type: 'image',
      allowed_formats: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      transformation: options.transformation || [],
      ...options
    };

    const result = await cloudinary.uploader.upload(file, uploadOptions);
    
    logger.info(`Image uploaded successfully: ${result.public_id}`);
    return {
      publicId: result.public_id,
      url: result.secure_url,
      width: result.width,
      height: result.height,
      format: result.format,
      size: result.bytes
    };
  } catch (error) {
    logger.error('Error uploading image to Cloudinary:', error);
    throw error;
  }
};

// Upload multiple images
const uploadMultipleImages = async (files, options = {}) => {
  try {
    const uploadPromises = files.map(file => uploadImage(file, options));
    const results = await Promise.all(uploadPromises);
    
    logger.info(`Multiple images uploaded successfully: ${results.length} files`);
    return results;
  } catch (error) {
    logger.error('Error uploading multiple images:', error);
    throw error;
  }
};

// Delete image from Cloudinary
const deleteImage = async (publicId) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const result = await cloudinary.uploader.destroy(publicId);
    
    if (result.result === 'ok') {
      logger.info(`Image deleted successfully: ${publicId}`);
      return { success: true, publicId };
    } else {
      throw new Error(`Failed to delete image: ${publicId}`);
    }
  } catch (error) {
    logger.error('Error deleting image from Cloudinary:', error);
    throw error;
  }
};

// Generate optimized URL
const getOptimizedUrl = (publicId, options = {}) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const defaultOptions = {
      width: 800,
      height: 600,
      crop: 'fill',
      quality: 'auto',
      format: 'auto'
    };

    const transformationOptions = { ...defaultOptions, ...options };
    
    return cloudinary.url(publicId, {
      transformation: [transformationOptions],
      secure: true
    });
  } catch (error) {
    logger.error('Error generating optimized URL:', error);
    throw error;
  }
};

// Upload data as metadata (for real-time sync)
const uploadMetadata = async (data, options = {}) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const metadataOptions = {
      folder: options.folder || 'zarya/metadata',
      resource_type: 'raw',
      public_id: options.publicId || `metadata_${Date.now()}`,
      context: {
        data: JSON.stringify(data),
        timestamp: new Date().toISOString(),
        type: options.type || 'sync_data'
      }
    };

    const result = await cloudinary.uploader.upload('data:text/plain;base64,', metadataOptions);
    
    logger.info(`Metadata uploaded successfully: ${result.public_id}`);
    return {
      publicId: result.public_id,
      url: result.secure_url,
      context: result.context
    };
  } catch (error) {
    logger.error('Error uploading metadata to Cloudinary:', error);
    throw error;
  }
};

// Get metadata from Cloudinary
const getMetadata = async (publicId) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const result = await cloudinary.api.resource(publicId, {
      resource_type: 'raw'
    });

    if (result.context && result.context.data) {
      return JSON.parse(result.context.data);
    }
    
    return null;
  } catch (error) {
    logger.error('Error getting metadata from Cloudinary:', error);
    throw error;
  }
};

// Create folder structure
const createFolder = async (folderPath) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    // Cloudinary creates folders automatically when you upload to them
    // This is just a helper function to ensure the folder structure exists
    logger.info(`Folder structure ensured: ${folderPath}`);
    return { success: true, folder: folderPath };
  } catch (error) {
    logger.error('Error creating folder structure:', error);
    throw error;
  }
};

// Get folder contents
const getFolderContents = async (folderPath, options = {}) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const result = await cloudinary.api.resources({
      type: 'upload',
      prefix: folderPath,
      max_results: options.maxResults || 100,
      ...options
    });

    return result.resources.map(resource => ({
      publicId: resource.public_id,
      url: resource.secure_url,
      format: resource.format,
      width: resource.width,
      height: resource.height,
      size: resource.bytes,
      createdAt: resource.created_at
    }));
  } catch (error) {
    logger.error('Error getting folder contents:', error);
    throw error;
  }
};

// Search resources
const searchResources = async (query, options = {}) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const result = await cloudinary.search
      .expression(query)
      .sort_by('created_at', 'desc')
      .max_results(options.maxResults || 100)
      .execute();

    return result.resources.map(resource => ({
      publicId: resource.public_id,
      url: resource.secure_url,
      format: resource.format,
      width: resource.width,
      height: resource.height,
      size: resource.bytes,
      createdAt: resource.created_at,
      context: resource.context
    }));
  } catch (error) {
    logger.error('Error searching resources:', error);
    throw error;
  }
};

// Generate signed upload URL
const generateSignedUploadUrl = (options = {}) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const uploadOptions = {
      folder: options.folder || 'zarya/uploads',
      resource_type: 'image',
      allowed_formats: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      ...options
    };

    const timestamp = Math.round(new Date().getTime() / 1000);
    const signature = cloudinary.utils.api_sign_request(uploadOptions, process.env.CLOUDINARY_API_SECRET);

    return {
      url: `https://api.cloudinary.com/v1_1/${process.env.CLOUDINARY_CLOUD_NAME}/image/upload`,
      params: {
        ...uploadOptions,
        timestamp,
        signature,
        api_key: process.env.CLOUDINARY_API_KEY
      }
    };
  } catch (error) {
    logger.error('Error generating signed upload URL:', error);
    throw error;
  }
};

// Get usage statistics
const getUsageStats = async () => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const result = await cloudinary.api.usage();
    
    return {
      plan: result.plan,
      objects: result.objects,
      bandwidth: result.bandwidth,
      storage: result.storage,
      requests: result.requests,
      resources: result.resources,
      derived_resources: result.derived_resources
    };
  } catch (error) {
    logger.error('Error getting usage statistics:', error);
    throw error;
  }
};

// Cleanup old resources
const cleanupOldResources = async (olderThanDays = 30, folder = null) => {
  try {
    if (!isInitialized) {
      throw new Error('Cloudinary not initialized');
    }

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

    const searchQuery = folder 
      ? `folder:${folder} AND created_at<${Math.round(cutoffDate.getTime() / 1000)}`
      : `created_at<${Math.round(cutoffDate.getTime() / 1000)}`;

    const oldResources = await searchResources(searchQuery, { maxResults: 1000 });
    
    const deletePromises = oldResources.map(resource => deleteImage(resource.publicId));
    const results = await Promise.allSettled(deletePromises);
    
    const successful = results.filter(result => result.status === 'fulfilled').length;
    const failed = results.filter(result => result.status === 'rejected').length;
    
    logger.info(`Cleanup completed: ${successful} deleted, ${failed} failed`);
    
    return { successful, failed, total: oldResources.length };
  } catch (error) {
    logger.error('Error during cleanup:', error);
    throw error;
  }
};

module.exports = {
  initialize,
  uploadImage,
  uploadMultipleImages,
  deleteImage,
  getOptimizedUrl,
  uploadMetadata,
  getMetadata,
  createFolder,
  getFolderContents,
  searchResources,
  generateSignedUploadUrl,
  getUsageStats,
  cleanupOldResources
};
