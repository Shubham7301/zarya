class CloudinaryConfig {
  // Real Cloudinary credentials from Zarya project
  static const String cloudName = 'zarya-booking';
  
  // API key (for backend use only - not exposed in client)
  static const String apiKey = '839433281873668';
  
  // API secret (for backend use only - not exposed in client)
  static const String apiSecret = 'e8-kMgVFUYWwfqI54Q4SAeEMkbc'; // Add your API secret here
  
  // Upload preset name from Cloudinary console
  static const String uploadPreset = 'zarya_uploads';
  
  // Base URLs for image delivery
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName';
  
  // Real-time configuration
  static const String realtimeUrl = 'wss://api.cloudinary.com/v1_1/$cloudName/realtime';
  static const String realtimeApiUrl = 'https://api.cloudinary.com/v1_1/$cloudName/realtime';
  
  // Database sync configuration
  static const String dbSyncUrl = 'https://api.cloudinary.com/v1_1/$cloudName/db-sync';
  static const String webhookUrl = 'https://api.cloudinary.com/v1_1/$cloudName/webhooks';
  
  // Default folders for different types of uploads
  static const String merchantProfileFolder = 'zarya/merchant-profiles';
  static const String serviceImagesFolder = 'zarya/service-images';
  static const String galleryImagesFolder = 'zarya/gallery-images';
  
  // Client-side restrictions (as per Aug 2025 updates)
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png', 
    'image/webp', 
    'image/gif'
  ];
  
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;
}
