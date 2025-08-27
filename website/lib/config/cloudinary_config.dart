class CloudinaryConfig {
  // Replace with YOUR actual cloud name from Step 3
  static const String cloudName = 'zarya-booking';
  
  // This will be your API key from Step 3 (for backend use only)
  static const String apiKey = '839433281873668';
  
  // Upload preset name from Step 4
  static const String uploadPreset = 'zarya_uploads';
  
  // Base URLs for image delivery
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName';
}
